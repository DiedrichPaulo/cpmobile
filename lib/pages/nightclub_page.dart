import "package:cp1mobile/models/pessoa.dart";
import "package:flutter/material.dart";
import "package:cp1mobile/repositories/pessoa_repository.dart";
import "package:cp1mobile/widgets/pessoa_item.dart";

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
  void mostrarFeedback(String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensagem),
          duration: const Duration(seconds: 3),
        ),
      );
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              isFull
                  ? "Camarote lotado! Não é possível registrar uma nova entrada."
                  : "Pode entrar",
              style: TextStyle(
                color: isFull ? Colors.red : Colors.green,
              ),
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
                  child: Icon(
                    Icons.add,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  for (Pessoa pessoa in listPessoas)
                    PessoaItem(
                      pessoa: pessoa,
                      onSaida: () => registrarSaida(pessoa),
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

  // Não permite campos vazios
  if (nome.isEmpty || identificacao.isEmpty) {
    setState(() {
      errorNome = nome.isEmpty
          ? "O nome não pode ser vazio"
          : null;
      errorId = identificacao.isEmpty
          ? "A identificação não pode ser vazia"
          : null;
    });
    return;
  }

  bool idRepetido = listPessoas.any(
    (pessoa) =>
        pessoa.identificacao == identificacao &&
        pessoa.noAmbiente,
  );

  if (idRepetido) {
    setState(() {
      errorNome = null;
      errorId = "Já tem uma pessoa com essa identificação no camarote";
    });

    mostrarFeedback(
      "Já existe uma pessoa com essa identificação no camarote!",
    );
    return;
  }

  if (isFull) {
    setState(() {
      errorNome = null;
      errorId = null;
    });

    mostrarFeedback(
      "Não é possível realizar a entrada. Ambiente lotado!",
    );
    return;
  }

  Pessoa newPessoa = Pessoa(
    nome: nome,
    identificacao: identificacao,
    dataEntrada: DateTime.now(),
  );

  setState(() {
    listPessoas.add(newPessoa);
    errorNome = null;
    errorId = null;
  });

  pessoaRepository.saveListaPessoas(listPessoas);

  nomeController.clear();
  idController.clear();

  mostrarFeedback("Pessoa cadastrada com sucesso!");
}


  
Future<void> registrarSaida(Pessoa pessoa) async {
  if (!pessoa.noAmbiente) {
    return;
  }

  final bool? confirmar = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text("Registrar saída?"),
        content: Text(
          "Deseja realmente registrar a saída de ${pessoa.nome}?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text("CONFIRMAR"),
          ),
        ],
      );
    },
  );

  if (confirmar != true || !mounted) {
    return;
  }

  if (!pessoa.noAmbiente) {
    return;
  }

  setState(() {
    pessoa.dataSaida = DateTime.now();
  });

  pessoaRepository.saveListaPessoas(listPessoas);

  mostrarFeedback("Saída registrada com sucesso!");
}

}
