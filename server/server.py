# -*- coding: utf-8 -*-
"""
Created on Sat May 24 18:33:52 2025

@author: Joel Tapia Salvador
"""
import environment
import utils


class Server(environment.http.server.BaseHTTPRequestHandler):

    def log_request(self, code='No Code', size='No Size'):
        if isinstance(code, environment.http.server.HTTPStatus):
            code = code.value
        message = self.requestline
        utils.print_message(
            f'Request: {message} | Code: {code} | Size: {size}'
            + f' | From: {self.client_address[0]}:{self.client_address[1]}'
        )

    def log_error(self, message_format, *args):
        utils.print_error(
            error=(
                f'Error: {args[1]} | Code: {args[0]}'
                + f' | From: {self.client_address[0]}:{self.client_address[1]}'
            ),
            print_stack=False,
        )

    def log_message(self, format, *args):
        pass

    def _set_headers(self, content_type='text/html'):
        self.send_response(200)
        self.send_header('Content-type', content_type)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()

    def _serve_file(self, file_path, content_type):
        if environment.os.path.exists(file_path):
            self._set_headers(content_type)
            with open(file_path, 'rb') as f:
                self.wfile.write(f.read())
        else:
            self.send_error(500, f'File Not Found: "{file_path}"')

    def do_GET(self):
        parsed_path = environment.urllib.parse.unquote(self.path)
        if parsed_path == '/css/global_styles.css':
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'css',
                    'global_styles.css',
                ),
                'text/css',
            )

        elif parsed_path == '/favicon.ico':
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'static',
                    'favicon.ico',
                ),
                'image/x-icon',
            )

        elif parsed_path == '/static/site.webmanifest':
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'static',
                    'site.webmanifest',
                ),
                'application/manifest+json',
            )

        elif parsed_path == '/static/android-chrome-192x192.png':
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'static',
                    'android-chrome-192x192.png',
                ),
                'image/png',
            )

        elif parsed_path == '/static/android-chrome-512x512.png':
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'static',
                    'android-chrome-512x512.png',
                ),
                'image/png',
            )

        elif parsed_path == '/static/apple-touch-icon.png':
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'static',
                    'apple-touch-icon.png',
                ),
                'image/png',
            )

        elif parsed_path == '/static/favicon-16x16.png':
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'static',
                    'favicon-16x16.png',
                ),
                'image/png',
            )

        elif parsed_path == '/static/favicon-32x32.png':
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'static',
                    'favicon-32x32.png',
                ),
                'image/png',
            )

        elif parsed_path == '/images/background_photo.jpeg':
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'images',
                    'background_photo.jpeg',
                ),
                'image/jpeg',
            )

        elif parsed_path == '/':
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'main',
                    'palestine.html',
                ),
                'text/html',
            )

        elif parsed_path == '/main/local_styles.css':
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'main',
                    'local_styles.css',
                ),
                'text/css',
            )
        elif parsed_path == '/graphs/bloody_toll':
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'graphs',
                    'bloody_toll',
                    'victimasdiarias.html',
                ),
                'text/html',
            )

        elif parsed_path == '/graphs/infrastructure_loss':
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'graphs',
                    'infrastructure_loss',
                    'infrastructure_loss.html',
                ),
                'text/html',
            )


        elif parsed_path == '/graphs/types_of_death':
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'graphs',
                    'types_of_death',
                    'piechart_race_combined.html',
                ),
                'text/html',
            )
        elif parsed_path == "/graphs/types_of_death/libs/htmlwidgets-1.6.4/htmlwidgets.js":
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'graphs',
                    'types_of_death',
                    'libs',
                    'htmlwidgets-1.6.4',
                    'htmlwidgets.js',
                ),
                'text/javascript',
            )
        elif parsed_path == "/graphs/types_of_death/libs/plotly-binding-4.10.4/plotly.js":
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'graphs',
                    'types_of_death',
                    'libs',
                    'plotly-binding-4.10.4',
                    'plotly.js',
                ),
                'text/javascript',
            )
        elif parsed_path == "/graphs/types_of_death/libs/typedarray-0.1/typedarray.min.js":
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'graphs',
                    'types_of_death',
                    'libs',
                    'typedarray-0.1',
                    'typedarray.min.js',
                ),
                'text/javascript',
            )
        elif parsed_path == "/graphs/types_of_death/libs/jquery-3.5.1/jquery.min.js":
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'graphs',
                    'types_of_death',
                    'libs',
                    'jquery-3.5.1',
                    'jquery.min.js',
                ),
                'text/javascript',
            )
        elif parsed_path == "/graphs/types_of_death/libs/crosstalk-1.2.1/js/crosstalk.min.js":
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'graphs',
                    'types_of_death',
                    'libs',
                    'crosstalk-1.2.1',
                    'js',
                    'crosstalk.min.js',
                ),
                'text/javascript',
            )
        elif parsed_path == "/graphs/types_of_death/libs/plotly-main-2.11.1/plotly-latest.min.js":
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'graphs',
                    'types_of_death',
                    'libs',
                    'plotly-main-2.11.1',
                    'plotly-latest.min.js',
                ),
                'text/javascript',
            )

        elif parsed_path == '/graphs/body_count':
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'graphs',
                    'body_count',
                    'body_count.html',
                ),
                'text/html',
            )

        elif parsed_path.split('?')[0] == '/graphs/body_count_view':
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'graphs',
                    'body_count',
                    'body_count_view.html',
                ),
                'text/html',
            )

        elif parsed_path == '/graphs/body_count/demographics_cum.json':
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'graphs',
                    'body_count',
                    'demographics_cum.json',
                ),
                'application/json',
            )

        elif parsed_path == '/graphs/body_count/body_count_files/htmlwidgets-1.6.4/htmlwidgets.js':
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'graphs',
                    'body_count',
                    'body_count_files',
                    'htmlwidgets-1.6.4',
                    'htmlwidgets.js'
                ),
                'text/javascript',
            )

        elif parsed_path == '/graphs/body_count/body_count_files/plotly-binding-4.10.4/plotly.js':
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'graphs',
                    'body_count',
                    'body_count_files',
                    'plotly-binding-4.10.4',
                    'plotly.js'
                ),
                'text/javascript',
            )

        elif parsed_path == '/graphs/body_count/body_count_files/typedarray-0.1/typedarray.min.js':
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'graphs',
                    'body_count',
                    'body_count_files',
                    'typedarray-0.1',
                    'typedarray.min.js'
                ),
                'text/javascript',
            )

        elif parsed_path == '/graphs/body_count/body_count_files/jquery-3.5.1/jquery.min.js':
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'graphs',
                    'body_count',
                    'body_count_files',
                    'jquery-3.5.1',
                    'jquery.min.js'
                ),
                'text/javascript',
            )

        elif parsed_path == '/graphs/body_count/body_count_files/crosstalk-1.2.1/js/crosstalk.min.js':
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'graphs',
                    'body_count',
                    'body_count_files',
                    'crosstalk-1.2.1',
                    'js',
                    'crosstalk.min.js',
                ),
                'text/javascript',
            )

        elif parsed_path == '/graphs/body_count/body_count_files/plotly-main-2.11.1/plotly-latest.min.js':
            self._serve_file(
                environment.os.path.join(
                    environment.PUBLIC_HTML_FILES_PATH,
                    'graphs',
                    'body_count',
                    'body_count_files',
                    'plotly-main-2.11.1',
                    'plotly-latest.min.js'
                ),
                'text/javascript',
            )

        else:
            self.send_error(404, f'Path "{self.path}" Not Found.')

    def do_POST(self):
        self.send_error(405, )


def run_server():
    http_server = environment.http.server.HTTPServer(
        (
            environment.SERVER_IP,
            environment.SERVER_PORT,
        ),
        Server,
    )
    utils.print_message(f'Starting server at {http_server.server_address}')

    try:
        http_server.serve_forever()
    except KeyboardInterrupt:
        utils.print_message('Server interrupted by user.')
    except Exception as error:
        utils.print_error(f'Unhandled server error: {error}')
    finally:
        http_server.server_close()
        utils.print_message('Server stopped.')


if __name__ == '__main__':
    try:
        environment.init()
        run_server()
    finally:
        environment.finish()
