import '../models/drama.dart';

List<Drama> initialDramas() {
  return const [
    Drama(
      id: '1',
      title: 'Bloody Flower',
      year: 2021,
      rating: 8.7,
      genres: ['Thriller'],
      tags: ['18+', 'Life'],
      synopsis: 'A mystery thriller about hidden secrets inside a small city.',
      posterAsset: 'assets/images/bloody_flower.jpg',
      isFavorite: true,
      isInMyList: true,
      mainCast: [
        CastMember(name: 'Ryeoun', photoAssetPath: 'assets/images/blood1.jpg'),
        CastMember(name: 'Sung Dong Il', photoAssetPath: 'assets/images/blood2.jpg'),
      ],
    ),
    Drama(
      id: '2',
      title: 'Our Universe',
      year: 2020,
      rating: 8.4,
      genres: ['Romance'],
      tags: ['Life'],
      synopsis:
          'A warm romance story that starts from a simple campus friendship.',
      posterAsset: 'assets/images/our_universe.jpg',
      isFavorite: true,
      isInMyList: false,
      mainCast: [
        CastMember(name: 'Bae In Hyuk', photoAssetPath: 'assets/images/our1.jpg'),
        CastMember(name: 'Roh Joeng Eui', photoAssetPath: 'assets/images/our2.jpg'),
      ],
    ),
    Drama(
      id: '3',
      title: 'Mouse',
      year: 2021,
      rating: 8.9,
      genres: ['Thriller'],
      tags: ['Crime'],
      synopsis: 'A detective drama that follows a string of shocking murders.',
      posterAsset: 'assets/images/mouse.jpg',
      isFavorite: false,
      isInMyList: true,
      mainCast: [
        CastMember(name: 'Lee Seung Gi', photoAssetPath: 'assets/images/mouse1.jpg'),
        CastMember(name: 'Lee Hee Joon', photoAssetPath: 'assets/images/mouse2.jpg'),
      ],
    ),
    Drama(
      id: '4',
      title: 'Sweet Home',
      year: 2020,
      rating: 8.3,
      genres: ['Horror'],
      tags: ['Action'],
      synopsis: 'Humans fight monsters while searching for hope and survival.',
      posterAsset: 'assets/images/sweet_home.jpg',
      isFavorite: true,
      isInMyList: true,
      mainCast: [
        CastMember(name: 'Song Kang', photoAssetPath: 'assets/images/sweet1.png'),
        CastMember(name: 'Lee Jin Wook', photoAssetPath: 'assets/images/sweet2.jpg'),
      ],
    ),
  ];
}
