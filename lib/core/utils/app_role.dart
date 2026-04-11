enum AppRole {
  user,
  admin,
  business,
  pharmacist,
  rider,
  labTech;

  String get id {
    switch (this) {
      case AppRole.user:
        return 'user';
      case AppRole.admin:
        return 'admin';
      case AppRole.business:
        return 'business';
      case AppRole.pharmacist:
        return 'pharmacist';
      case AppRole.rider:
        return 'rider';
      case AppRole.labTech:
        return 'lab_tech';
    }
  }

  String get label {
    switch (this) {
      case AppRole.user:
        return 'User';
      case AppRole.admin:
        return 'Admin';
      case AppRole.business:
        return 'Business';
      case AppRole.pharmacist:
        return 'Pharmacist';
      case AppRole.rider:
        return 'Rider';
      case AppRole.labTech:
        return 'Lab Tech';
    }
  }

  String get dashboardTitle {
    switch (this) {
      case AppRole.user:
        return 'HealMeal - User';
      case AppRole.admin:
        return 'HealMeal - Admin';
      case AppRole.business:
        return 'HealMeal Business';
      case AppRole.pharmacist:
        return 'HealMeal - Pharmacist';
      case AppRole.rider:
        return 'HealMeal - Rider';
      case AppRole.labTech:
        return 'HealMeal - Lab Tech';
    }
  }

  String get homeRoute {
    switch (this) {
      case AppRole.user:
        return '/home';
      case AppRole.admin:
        return '/admin';
      case AppRole.business:
        return '/account/business';
      case AppRole.pharmacist:
        return '/pharmacist';
      case AppRole.rider:
        return '/rider';
      case AppRole.labTech:
        return '/lab-tech';
    }
  }

  static AppRole fromStorage(String? rawValue) {
    switch (rawValue) {
      case 'user':
      case 'patient':
        return AppRole.user;
      case 'admin':
        return AppRole.admin;
      case 'business':
        return AppRole.business;
      case 'pharmacist':
        return AppRole.pharmacist;
      case 'rider':
        return AppRole.rider;
      case 'lab_tech':
        return AppRole.labTech;
      default:
        return AppRole.user;
    }
  }
}
