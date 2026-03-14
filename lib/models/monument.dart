class Monument {
  final String name;
  final String imagePath;
  final double latitude;
  final double longitude;
  final double altitude;
  final double heading;
  final double tilt;
  final double range;
  final String country;
  final String yearOfInscription;
  final String category;
  final String description;

  const Monument({
    required this.name,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    this.altitude = 0,
    this.heading = 0,
    this.tilt = 60,
    this.range = 1000,
    required this.country,
    required this.yearOfInscription,
    required this.category,
    required this.description,
  });

  static const List<Monument> monuments = [
    Monument(
      name: 'Taj Mahal',
      imagePath: 'assets/images/taj_mahal.png',
      latitude: 27.1751,
      longitude: 78.0421,
      altitude: 0,
      heading: 0,
      tilt: 60,
      range: 800,
      country: 'India',
      yearOfInscription: '1983',
      category: 'Cultural Heritage',
      description:
          'The Taj Mahal is one of the most famous monuments in the world '
          'and a masterpiece of Mughal architecture.\n\n'
          'Built in the seventeenth century by Emperor Shah Jahan in memory '
          'of his wife Mumtaz Mahal. It is an exquisite white marble mausoleum '
          'endowed with inlaid land and precious stone material domes, '
          'and attracts millions of visitors from gardens across the globe.',
    ),
    Monument(
      name: 'Petra',
      imagePath: 'assets/images/petra.png',
      latitude: 30.3285,
      longitude: 35.4444,
      altitude: 0,
      heading: 0,
      tilt: 60,
      range: 1000,
      country: 'Jordan',
      yearOfInscription: '1985',
      category: 'Cultural Heritage',
      description:
          'Petra is a famous archaeological site in Jordan\'s southwestern desert. '
          'Dating to around 300 B.C., it was the capital of the Nabataean Kingdom.\n\n'
          'Accessed via a narrow canyon called Al-Siq, it contains tombs and '
          'temples carved into pink sandstone cliffs, earning its nickname '
          '"The Rose City". Its most famous structure is Al-Khazneh, a Greek-style temple.',
    ),
    Monument(
      name: 'Machu Picchu',
      imagePath: 'assets/images/machu_picchu.png',
      latitude: -13.1631,
      longitude: -72.5450,
      altitude: 0,
      heading: 0,
      tilt: 60,
      range: 1200,
      country: 'Peru',
      yearOfInscription: '1983',
      category: 'Mixed Heritage',
      description:
          'Machu Picchu is a 15th-century Inca citadel situated on a mountain '
          'ridge 2,430 metres above sea level in the Cusco Region of Peru.\n\n'
          'It is the most familiar icon of Inca civilization. Built in the '
          'classical Inca style with polished dry-stone walls, it was '
          'abandoned during the Spanish Conquest and remained unknown until 1911.',
    ),
    Monument(
      name: 'Pyramids of Giza',
      imagePath: 'assets/images/pyramids.png',
      latitude: 29.9792,
      longitude: 31.1342,
      altitude: 0,
      heading: 0,
      tilt: 60,
      range: 2000,
      country: 'Egypt',
      yearOfInscription: '1979',
      category: 'Cultural Heritage',
      description:
          'The Pyramids of Giza are the oldest of the Seven Wonders of the '
          'Ancient World. They were built as tombs for the Pharaohs.\n\n'
          'The Great Pyramid of Khufu is the largest, originally standing at '
          '146.6 metres. The complex also includes the Great Sphinx, a '
          'limestone statue of a mythical creature with a lion\'s body and a human head.',
    ),
  ];
}
