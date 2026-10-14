import "package:cp1mobile/models/pessoa.dart";
import "package:flutter/material.dart";
import "package:cp1mobile/repositories/pessoa_repository.dart";

//Regra do CP1: o camarote aguenta no máximo 64 pessoas
const int capacidadeMaxima = 64;

List<Pessoa> listPessoas = [];
String? errorNome;
String? errorId;

final PessoaRepository pessoaRepository = PessoaRepository();
final TextEditingController nomeController = TextEditingController();
final TextEditingController idController = TextEditingController();

class NightclubPage extends StatefulWidget {
  const NightclubPage({super.key});

  @override
  State<NightclubPage> createState() => _NightclubPageState();
}

class _NightclubPageState extends State<NightclubPage> {
  @override
  void initState(){
    super.initState();
    pessoaRepository.getListaPessoas().then((value){
      setState(() {
        listPessoas = value;
      });
    });
  }

  //Conta só quem ainda está dentro, quem já saiu não entra na conta
  int get pessoasNoAmbiente => listPessoas.where((pessoa) => pessoa.noAmbiente).length;

  bool get isFull => pessoasNoAmbiente >= capacidadeMaxima;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          "Camarote VIP",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                "Pessoas no ambiente: $pessoasNoAmbiente / $capacidadeMaxima",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                isFull ? "Camarote lotado! Não é possível registrar uma nova entrada." : "Pode entrar",
                style: TextStyle(color: isFull ? Colors.red : Colors.green),
              ),
              SizedBox(height: 16),
              TextField(
                controller: nomeController,
                decoration: InputDecoration(
                  labelText: "Nome",
                  hintText: "Ex: Maria Silva",
                  errorText: errorNome,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: idController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Identificação",
                        hintText: "Ex: 123456",
                        errorText: errorId,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: cadastrarPessoa,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: Icon(Icons.add, size: 30, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    for (Pessoa pessoa in listPessoas)
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 2),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.grey[200],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pessoa.nome,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                  Text("ID: ${pessoa.identificacao}"),
                                  //TODO: formatar essa data com o intl
                                  Text("Entrada: ${pessoa.dataEntrada}"),
                                  Text("Situação: ${pessoa.situacao}"),
                                ],
                              ),
                            ),
                            TextButton(
                              //Se a pessoa já saiu o botão fica desabilitado
                              onPressed: pessoa.noAmbiente ? () => registrarSaida(pessoa) : null,
                              child: Text("Saída"),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void cadastrarPessoa() {
    String nome = nomeController.text.trim();
    String identificacao = idController.text.trim();

    //Regra 3: não deixa cadastrar com campo vazio
    if (nome.isEmpty || identificacao.isEmpty) {
      setState(() {
        errorNome = nome.isEmpty ? "O nome não pode ser vazio" : null;
        errorId = identificacao.isEmpty ? "A identificação não pode ser vazia" : null;
      });
      return;
    }

    //Regra 4: não pode ter duas pessoas com a mesma identificação dentro do camarote
    bool idRepetido = listPessoas.any(
      (pessoa) => pessoa.identificacao == identificacao && pessoa.noAmbiente,
    );
    if (idRepetido) {
      setState(() {
        errorNome = null;
        errorId = "Já tem uma pessoa com essa identificação no camarote";
      });
      return;
    }

    //Regra 1: se estiver lotado ninguém entra
    if (isFull) {
      setState(() {
        errorNome = null;
        errorId = null;
      });
      return;
    }

    setState(() {
      Pessoa newPessoa = Pessoa(
        nome: nome,
        identificacao: identificacao,
        dataEntrada: DateTime.now(),
      );
      listPessoas.add(newPessoa);
      errorNome = null;
      errorId = null;
    });
    pessoaRepository.saveListaPessoas(listPessoas);
    nomeController.clear();
    idController.clear();
  }

  void registrarSaida(Pessoa pessoa) {
    //Regra 2: quem já saiu não pode registrar a saída de novo
    if (!pessoa.noAmbiente) {
      return;
    }
    setState(() {
      pessoa.dataSaida = DateTime.now();
    });
    pessoaRepository.saveListaPessoas(listPessoas);
  }
}
