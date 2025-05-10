import pandas as pd

df = pd.read_csv("chronology_nodes.csv")

# Filtrar registros inválidos: sin fecha o sin contenido útil
invalid_rows = df[df["date"].isna() | df["content"].isna() | (df["content"].str.strip() == "")]
valid_rows = df.drop(index=invalid_rows.index)
valid_rows.to_csv("chronology_nodes_clean.csv", index=False)
invalid_rows.to_csv("chronology_nodes_dirty.csv", index=False)


with open("chronology_nodes_removed.txt", "w", encoding="utf-8") as f:
    total = len(invalid_rows)
    f.write(f"Se eliminaron {total} registros del CSV original.\n")
    f.write("Causa: el registro no contiene una fecha válida o contenido (campo 'content') está vacío o ausente.\n\n")
    f.write("Lista de node_id eliminados:\n")
    for node_id in invalid_rows["node_id"]:
        f.write(f"{node_id}\n")

# Imprimir en consola el resumen
print(f"Se eliminaron {len(invalid_rows)} registros inválidos. CSV limpio guardado como 'chronology_nodes_clean.csv'.")
