import '../models/doctor_model.dart';

final List<Doctor> doctors = [
  Doctor(
    name: "Jennifer Kay",
    role: "Psychologist",
    rating: 4.8,
    image: "https://cdn-icons-png.flaticon.com/512/8815/8815112.png",
    slots: [
      {
        "date": "Wed\n20",
        "times": ["9.00 AM", "10.30 AM", "4.00 PM"],
      },
      {
        "date": "Thu\n21",
        "times": ["8.00 AM", "11.00 AM", "3.00 PM"],
      },
    ],
  ),
  Doctor(
    name: "Gary Olson",
    role: "Therapist",
    rating: 4.7,
    image: "https://cdn-icons-png.flaticon.com/512/2922/2922506.png",
    slots: [
      {
        "date": "Fri\n22",
        "times": ["9.00 AM", "12.00 PM", "6.00 PM"],
      },
      {
        "date": "Sat\n23",
        "times": ["10.00 AM", "1.00 PM", "3.00 PM"],
      },
    ],
  ),
  Doctor(
    name: "Dr. Yuki Tanaka",
    role: "Psychologist",
    rating: 4.9,
    image: "https://cdn-icons-png.flaticon.com/512/4323/4323859.png",
    slots: [
      {
        "date": "Sun\n24",
        "times": ["10.00 AM", "2.00 PM", "6.00 PM"],
      },
    ],
  ),
];
