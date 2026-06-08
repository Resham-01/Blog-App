import 'package:blog_app/core/enums/user_role.dart';
import 'package:blog_app/features/auth/domain/entities/user.dart';
import 'package:blog_app/features/dashboard/presentation/pages/institution_admin_dashboard_page.dart';
import 'package:blog_app/features/dashboard/presentation/pages/parent_dashboard_page.dart';
import 'package:blog_app/features/dashboard/presentation/pages/super_admin_dashboard_page.dart';
import 'package:flutter/material.dart';

class DashboardRouter {
  static Route<void> routeFor(User user) {
    switch (user.role) {
      case UserRole.superAdmin:
        return SuperAdminDashboardPage.route(user: user);
      case UserRole.schoolAdmin:
      case UserRole.collegeAdmin:
        return InstitutionAdminDashboardPage.route(user: user);
      case UserRole.parent:
        return ParentDashboardPage.route(user: user);
    }
  }

  static void navigate(BuildContext context, User user) {
    Navigator.pushReplacement(context, routeFor(user));
  }
}
