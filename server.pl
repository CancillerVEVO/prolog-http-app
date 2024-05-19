:- use_module(library(http/http_server)).

:- initialization
    http_server([port(3000)]).

% Define la ruta /book 
:- http_handler('/books', book_handler, []).
% Define la ruta /books/recomendations 
:- http_handler('/books/recommendations', book_recommendations_handler, []).

% Carga la base de datos de libros
:- consult('books.pl').

% Handler de /books
book_handler(_Request) :-
    format('Content-type: text/html~n~n', []),
    format('<html><head><title>Libros</title></head><body>', []),
    format('<h1>Book</h1>', []),
    format('<form action="/books/recommendations" method="get">', []),
    format('<label for="genres">Generos:</label>', []),
    format('<input type="text" id="genres" name="genres">', []),
    format('<input type="submit" value="Submit">', []),
    format('</form>', []),
    format('</body></html>', []).


% Handler de /books/recommendations
book_recommendations_handler(Request) :-
    http_parameters(Request, [genres(Genres, [])]),
    % Separa la lista de géneros por comas
    atomic_list_concat(GenreList, ',', Genres),
    % Encuentra los libros que contienen al menos uno de los géneros
    findall(Title, (book(Title, _, _, _, GenresOfBook), member(Genre, GenreList), member(Genre, GenresOfBook)), Recommendations),
    length(Recommendations, Total),
    format('Content-type: text/html~n~n', []),
    format('<style> .no-books { color: red; font-style: italic; } </style>', []),
    format('<html><head><title>Book Recommendations</title></head><body>', []),
    format('<h1>Book Recommendations</h1>', []),
    format('<p>Recomendaciones basadas en los géneros: ~w</p>', [Genres]),
    format('<p>Total de resultados: ~w</p>', [Total]),
    format('<a href="/books">Volver a la página de libros</a>', []),
    (
    Recommendations = []
    ->  % Si no hay recomendaciones, muestra un mensaje
        format('<p class="no-books">No hay libros para mostrar en este momento.</p>', [])
    ;   % Si hay recomendaciones, muestra la lista de libros
        format('<ul>', []),
        % Muestra las recomendaciones
        display_recommendations(Recommendations),
        format('</ul>', [])
    ),
    format('</body></html>', []).

% Predicado para mostrar las recomendaciones
display_recommendations([]).
display_recommendations([Title|Rest]) :-
    book(Title, Author, Year, Description, Genres),
    format('<div style="padding: 10px; margin: 10px; border: 1px solid black; border-radius: 10px;">', []),
    format('<b>Título:</b> ~w<br>', [Title]),
    format('<b>Autor:</b> ~w<br>', [Author]),
    format('<b>Año:</b> ~w<br>', [Year]),
    format('<b>Descripción:</b> ~w<br>', [Description]),
    format('<b>Géneros:</b> ~w<br>', [Genres]),
    format('</div>', []),
    nl, 
    display_recommendations(Rest).