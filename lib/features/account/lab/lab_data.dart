class LabOrderData {
  const LabOrderData({
    required this.id,
    required this.testName,
    required this.patientName,
    required this.ageGender,
    required this.date,
    required this.status,
    required this.collectionSlot,
  });

  final String id;
  final String testName;
  final String patientName;
  final String ageGender;
  final DateTime date;
  final String status;
  final String collectionSlot;
}

class ReportData {
  const ReportData({
    required this.testName,
    required this.patientName,
    required this.date,
  });

  final String testName;
  final String patientName;
  final DateTime date;
}

class PatientData {
  const PatientData({
    required this.name,
    required this.age,
    required this.gender,
    required this.relation,
    this.isSelf = false,
  });

  final String name;
  final int age;
  final String gender;
  final String relation;
  final bool isSelf;
}

final List<LabOrderData> initialLabOrders = [
  LabOrderData(
    id: '#LAB-20260405-001',
    testName: 'Dengue Package',
    patientName: 'Arif Hasan',
    ageGender: '35F',
    date: DateTime(2026, 4, 5),
    status: 'upcoming',
    collectionSlot: 'Today 8-10 AM',
  ),
  LabOrderData(
    id: '#LAB-20260403-087',
    testName: 'CBC',
    patientName: 'Md Rafi',
    ageGender: '28M',
    date: DateTime(2026, 4, 3),
    status: 'completed',
    collectionSlot: 'Completed 3 Apr',
  ),
  LabOrderData(
    id: '#LAB-20260401-044',
    testName: 'Thyroid Profile',
    patientName: 'Tania Akter',
    ageGender: '42F',
    date: DateTime(2026, 4, 1),
    status: 'processing',
    collectionSlot: 'Collected, processing',
  ),
  LabOrderData(
    id: '#LAB-20260329-011',
    testName: 'Lipid Profile',
    patientName: 'Rahman Karim',
    ageGender: '51M',
    date: DateTime(2026, 3, 29),
    status: 'cancelled',
    collectionSlot: 'Cancelled by user',
  ),
];

final List<ReportData> initialLabReports = [
  ReportData(
    testName: 'CBC',
    patientName: 'Arif Hasan',
    date: DateTime(2026, 4, 3),
  ),
  ReportData(
    testName: 'Dengue Package',
    patientName: 'Md Rafi',
    date: DateTime(2026, 3, 28),
  ),
];

final List<PatientData> defaultPatients = [
  const PatientData(
    name: 'Arif Hasan',
    age: 35,
    gender: 'male',
    relation: 'Self',
    isSelf: true,
  ),
  const PatientData(name: 'Md Rafi', age: 28, gender: 'Male', relation: 'Brother'),
  const PatientData(
    name: 'Fatema Akter',
    age: 62,
    gender: 'Female',
    relation: 'Mother',
  ),
];
