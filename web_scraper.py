import argparse
import csv
import logging
import time
from pathlib import Path
from typing import Dict, List, Optional
from urllib.parse import urljoin

import requests
from bs4 import BeautifulSoup
from dateutil import parser as dateparser

BASE_URL = "https://chronology.palestine-studies.org"
HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (X11; Linux x86_64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/123.0 Safari/537.36 "
        "VD-ProjectScraper/1.2 (+https://github.com/your-org)"
    )
}

FIELDNAMES = [
    "node_id",
    "date",
    "weekday",
    "content",
    "links",
    "keywords",
    "url",
]

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def fetch_html(url: str, *, timeout: int = 15) -> Optional[str]:
    """Download page HTML. Returns `None` on error."""
    try:
        resp = requests.get(url, headers=HEADERS, timeout=timeout)
        if resp.status_code == 200:
            return resp.text
        logging.warning("%s returned status %s", url, resp.status_code)
    except requests.RequestException as exc:
        logging.warning("%s raised %s", url, exc)
    return None


def clean_content(content_div: BeautifulSoup) -> str:
    """Remove source acronyms (anchor tags) and return pretty text."""
    # 1) Collect links & delete anchor tags so the acronyms disappear from text
    for a in content_div.find_all("a", href=True):
        a.decompose()

    # 2) Preserve paragraph structure — one blank line between <p>
    paragraphs = [p.get_text(" ", strip=True) for p in content_div.find_all("p")]
    if paragraphs:
        return "\n\n".join(paragraphs)
    # Fallback: no <p> tags detected
    return content_div.get_text(" ", strip=True)


# ---------------------------------------------------------------------------
# Core extractors
# ---------------------------------------------------------------------------

def parse_node(html: str, node_id: int, url: str) -> Dict[str, str]:
    soup = BeautifulSoup(html, "lxml")

    # --- Date & weekday ------------------------------------------------------
    date_tag = soup.select_one("span.date-display-single")
    raw_date = date_tag.get_text(strip=True) if date_tag else ""
    date_iso, weekday = "", ""
    if raw_date:
        try:
            dt = dateparser.parse(raw_date, fuzzy=True)
            date_iso = dt.date().isoformat()
            weekday = dt.strftime("%A")
        except (ValueError, TypeError) as exc:
            logging.warning("Unable to parse date '%s' (node %s): %s", raw_date, node_id, exc)

    # --- Main content --------------------------------------------------------
    content_div = soup.select_one('div.field-item[property="content:encoded"]')
    if content_div is None:
        content_div = soup.select_one("div.field-name-body div.field-item")

    content_text: str = ""
    links: List[str] = []
    if content_div is not None:
        # Gather links BEFORE decompose, to keep hrefs
        for a in content_div.find_all("a", href=True):
            href = a["href"].strip()
            full = urljoin(BASE_URL, href) if href.startswith("/") else href
            links.append(full)
        # Remove anchor tags & prettify text
        content_text = clean_content(content_div)
    links_str = "; ".join(dict.fromkeys(links))  # de‑duplicate preserving order

    # --- Keywords ------------------------------------------------------------
    kw_div = soup.find("div", class_="keywords")
    keywords: List[str] = []
    if kw_div:
        keywords = [a.get_text(strip=True) for a in kw_div.find_all("a") if a.text]
    keywords_str = "; ".join(dict.fromkeys(keywords))

    return {
        "node_id": str(node_id),
        "date": date_iso,
        "weekday": weekday,
        "content": content_text,
        "links": links_str,
        "keywords": keywords_str,
        "url": url,
    }


# ---------------------------------------------------------------------------
# Driver functions
# ---------------------------------------------------------------------------

def scrape_range(start: int, end: int, *, delay: float = 1.0) -> List[Dict[str, str]]:
    """Iterate through node IDs and collect parsed records."""
    records: List[Dict[str, str]] = []
    for node_id in range(start, end + 1):
        url = f"{BASE_URL}/node/{node_id}"
        logging.info("Fetching node %s", node_id)
        html = fetch_html(url)
        if html:
            record = parse_node(html, node_id, url)
            records.append(record)
        time.sleep(delay)
    return records


def write_csv(data: List[Dict[str, str]], outfile: Path) -> None:
    with outfile.open("w", encoding="utf-8-sig", newline="") as fh:
        writer = csv.DictWriter(fh, fieldnames=FIELDNAMES)
        writer.writeheader()
        writer.writerows(data)
    logging.info("CSV written to %s", outfile)


# ---------------------------------------------------------------------------
# CLI entry‑point
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(description="Scraper for The Palestine Chronology")
    parser.add_argument("-s", "--start", type=int, default=14073, help="First node (inclusive)")
    parser.add_argument("-e", "--end", type=int, default=17122, help="Last node (inclusive)")
    parser.add_argument("-o", "--output", type=Path, default=Path("chronology_nodes.csv"), help="CSV output file")
    parser.add_argument("-d", "--delay", type=float, default=1.0, help="Delay between requests in seconds")
    args = parser.parse_args()

    logging.basicConfig(level=logging.INFO, format="%(asctime)s | %(levelname)s | %(message)s")

    records = scrape_range(args.start, args.end, delay=args.delay)
    write_csv(records, args.output)


if __name__ == "__main__":
    main()
