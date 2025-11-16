class Meal {
  final String idMeal;
  final String strMeal;
  final String strCategory;
  final String strArea;
  final String strMealThumb;
  final String strInstructions;

  Meal({
    required this.idMeal,
    required this.strMeal,
    required this.strCategory,
    required this.strArea,
    required this.strMealThumb,
    required this.strInstructions,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      idMeal: json['idMeal'] as String,
      strMeal: json['strMeal'] as String? ?? 'Nama Tidak Diketahui',
      strCategory: json['strCategory'] as String? ?? 'Uncategorized',
      strArea: json['strArea'] as String? ?? 'Unknown',
      strInstructions: json['strInstructions'] as String? ?? 'Tidak ada instruksi tersedia.',
      strMealThumb: json['strMealThumb'] as String? ?? '',
    );
  }
}