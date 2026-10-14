import 'package:shared_preferences/shared_preferences.dart';
import 'package:cp1mobile/models/pessoa.dart';
import 'dart:convert';

const pessoaListKey = "lista_pessoas";

class PessoaRepository {
  PessoaRepository(){
    SharedPreferences.getInstance().then((value)=>sharedPreferences=value);
  }

  late SharedPreferences sharedPreferences;

  void saveListaPessoas(List<Pessoa>pessoas){
    final jsonString  = json.encode(pessoas);
    sharedPreferences.setString(pessoaListKey, jsonString);
  }

  Future<List<Pessoa>>getListaPessoas()async{
    sharedPreferences = await SharedPreferences.getInstance();
    
    final String jsonString = sharedPreferences.getString(pessoaListKey)??"[]";
    final List jsonDecoded = json.decode(jsonString) as List;

    return jsonDecoded.map((e)=>Pessoa.fromJson(e)).toList();
  }
}