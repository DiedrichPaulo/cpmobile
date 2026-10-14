class Pessoa {
  Pessoa({required this.nome, required this.identificacao, required this.dataEntrada, this.dataSaida});
  //Construtor nomeado
  Pessoa.fromJson(Map<String,dynamic>json)
    :nome = json["nome"],
     identificacao = json["identificacao"],
     dataEntrada = DateTime.parse(json["dataEntrada"]),
     dataSaida = json["dataSaida"] != null ? DateTime.parse(json["dataSaida"]) : null;

  String nome;
  String identificacao;
  DateTime dataEntrada;
  DateTime? dataSaida; //fica null enquanto a pessoa estiver na balada

  //Se ainda não tem data de saída é porque a pessoa está no ambiente
  bool get noAmbiente => dataSaida == null;

  String get situacao => noAmbiente ? "No ambiente" : "Saiu";

  //Converter o objeto Pessoa para um Map.
  //Estou convertendo para map para depois transformar em JSON
  Map<String,dynamic>toJson(){
    return {
      "nome":nome,
      "identificacao":identificacao,
      "dataEntrada":dataEntrada.toIso8601String(),
      "dataSaida":dataSaida?.toIso8601String()
    };
  }
}
