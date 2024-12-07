import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FlutoStorageProvider  extends ChangeNotifier {
  Supabase? supabase;
  init({
    Supabase? supabase,
  }){
    this.supabase = supabase;
    notifyListeners();
  }
  
}