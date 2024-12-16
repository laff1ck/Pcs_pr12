import 'package:flutter/material.dart';
import 'package:pr_12/models/api_service.dart';
import 'package:pr_12/components/item.dart';
import 'package:pr_12/components/note_card.dart';
import 'package:pr_12/models/note.dart';
import 'package:pr_12/models/cart.dart';
import 'fav_page.dart';
import 'prof_page.dart';
import 'create_note_page.dart';
import 'basket.dart';
import 'edit_page.dart';
import 'note_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Note> notes = [];
  List<Note> favorites = [];
  List<CartItem> cart = [];
  final ApiService apiService = ApiService();

  // Переменные для фильтрации, поиска и сортировки
  String? _selectedCategory;
  String _sortOrder = 'asc'; // 'asc' - по возрастанию, 'desc' - по убыванию
  String _searchQuery = '';
  final List<String> categories = ['Все', 'Торты', 'Макаруны', 'Десерты'];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      List<Note> products = await apiService.getProducts();
      setState(() {
        notes = products;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки товаров: $e')),
      );
    }
  }

  void _addNote(Note note) {
    setState(() {
      notes.add(note);
    });
  }

  void _editNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditPage(
              note: note,
              onUpdate: (updatedNote) {
                setState(() {
                  int index = notes.indexWhere((n) => n.id == updatedNote.id);
                  if (index != -1) {
                    notes[index] = updatedNote;
                  }
                });
              },
            ),
      ),
    );
  }

  void _addToCart(Note note) {
    setState(() {
      cart.add(CartItem(note: note));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${note.title} добавлен в корзину')),
    );
  }

  void _openNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            NotePage(
              note: note,
              onUpdate: (updatedNote) {
                setState(() {
                  int index = notes.indexWhere((n) => n.id == updatedNote.id);
                  if (index != -1) {
                    notes[index] = updatedNote; // Обновляем заметку
                  }
                });
              },
            ),
      ),
    );
  }

  void _deleteNote(int id) {
    setState(() {
      notes.removeWhere((note) => note.id == id);
    });
  }

  void _toggleFavorite(Note note) {
    setState(() {
      if (favorites.contains(note)) {
        favorites.remove(note);
        note.isFav = false;
      } else {
        favorites.add(note);
        note.isFav = true;
      }
    });
  }

  void _removeFromFavorites(Note note) {
    setState(() {
      favorites.remove(note);
      note.isFav = false;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Note> _getFilteredAndSortedNotes() {
    List<Note> filteredNotes = List.from(notes);

    // Фильтрация по категории
    if (_selectedCategory != null && _selectedCategory != 'Все') {
      filteredNotes = filteredNotes
          .where((note) => note.category.trim().toLowerCase() == _selectedCategory!.trim().toLowerCase())
          .toList();
    }

    // Поиск по названию
    if (_searchQuery.isNotEmpty) {
      filteredNotes = filteredNotes
          .where((note) => note.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Сортировка
    filteredNotes.sort((a, b) {
      int comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
      return _sortOrder == 'asc' ? comparison : -comparison;
    });

    return filteredNotes;
  }


  @override
  Widget build(BuildContext context) {
    Widget getCurrentPage() {
      switch (_selectedIndex) {
        case 0:
          return _buildNoteList(); // Только на главной странице показывается фильтр и сортировка
        case 1:
          return FavPage(
            favorites: favorites,
            onOpenNote: _openNote,
            // Передаем функцию для открытия
            onRemoveFromFavorites: _removeFromFavorites,
            // Передаем функцию для удаления
            onAddToCart: _addToCart,
          );
        case 2:
          return ProfPage();
        default:
          return _buildNoteList();
      }
    }

    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(211, 181, 169, 165), // Цвет фона
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Лавочка'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CreateNotePage(onCreate: _addNote),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart), // Иконка корзины
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CartPage(cartItems: cart), // Передаем корзину
                  ),
                );
              },
            ),
          ],
        ),
        body: _selectedIndex ==
            0 // Фильтр и сортировка только на главной странице
            ? Column(
          children: [
            // Фильтрация, поиск и сортировка
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Поиск
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Поиск по названию',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Фильтр по категориям
                      DropdownButton<String>(
                        value: _selectedCategory,
                        hint: const Text('Фильтр'),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                        items: categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                      ),
                      // Сортировка
                      IconButton(
                        icon: Icon(
                          _sortOrder == 'asc' ? Icons.arrow_upward : Icons
                              .arrow_downward,
                        ),
                        onPressed: () {
                          setState(() {
                            _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc';
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(child: getCurrentPage()), // Отображаем текущую страницу
          ],
        )
            : getCurrentPage(),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Избранные',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color.fromARGB(211, 255, 153, 115),
          unselectedItemColor: const Color.fromARGB(211, 193, 193, 193),
        ),
      ),
    );
  }

  Widget _buildNoteList() {
    // Получаем отфильтрованные и отсортированные данные
    List<Note> filteredAndSortedNotes = _getFilteredAndSortedNotes();

    if (filteredAndSortedNotes.isEmpty) {
      return const Center(
        child: Text(
          'Товары не найдены',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    // Отображаем товары в виде сетки
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: filteredAndSortedNotes.length,
      itemBuilder: (context, index) {
        final note = filteredAndSortedNotes[index];
        return NoteCard(
          note: note,
          onTap: (note) => _openNote(note),
          onToggleFavorite: (note) => _toggleFavorite(note),
          onAddToCart: (note) => _addToCart(note),
        );
      },
    );
  }
}