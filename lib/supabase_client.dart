import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://dfccorjkvgvigzrpbiny.supabase.co';
const supabasePublishableKey = 'sb_publishable_B-GnoN9_X77tC-vsbihLHw_CwJnqLxl';

SupabaseClient get supabase => Supabase.instance.client;
