//
//  CalendarioMensalView.swift
//  Spark
//
//  Created by Jota Pe on 11/03/26.
//

import SwiftUI

struct CalendarioMensalView: View {
    @EnvironmentObject var gerenciadorSessoes: GerenciadorSessoesViewModel
    
    @Binding var sessaoSelecionada: SessaoDeTreino?
    @Binding var mostrarDetalhe: Bool
    
    @State private var dataAtual = Date()
    
    let corDestaqueTreino = Color(Color(red: 233/255, green: 9/255, blue: 22/255))
    let corTextoPadrao = Color.white
    let corFundoCalendario = Color("ColorCard")
    
    let diasDaSemana = ["D", "S", "T", "Q", "Q", "S", "S"]
    let colunas = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Button(action: mesAnterior) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .padding(.trailing, 10)
                }
                Spacer()
                Text(mesEAnoString(de: dataAtual))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                Button(action: proximoMes) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                        .padding(.leading, 10)
                }
            }
            .padding(.horizontal)
        
            HStack {
                ForEach(diasDaSemana, id: \.self) { dia in
                    Text(dia)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
        
            LazyVGrid(columns: colunas, spacing: 10) {
                ForEach(obterDiasDoMes(), id: \.self) { data in
                    if let data = data {
                        let infoTreino = obterInfoTreino(na: data)
                        let treinouNesteDia = (infoTreino != nil)
                        
                        DiaCalendarioView(
                            data: data,
                            treinouNesteDia: treinouNesteDia,
                            corDestaque: corDestaqueTreino,
                            corTexto: corTextoPadrao
                        )
                        .onTapGesture {
                            if let info = infoTreino {
                                if let exercicios = info.exerciciosExecutados {
                                    let sessaoParaExibicao = SessaoDeTreino(
                                        id: info.idSessao,
                                        nomeSessao: info.nomeSessao,
                                        exercicios: exercicios,
                                        dataCriacao: info.dataConclusao,
                                        isModeloIntocado: false
                                    )
                                    self.sessaoSelecionada = sessaoParaExibicao
                                    self.mostrarDetalhe = true
                                } else {
                                    if let sessaoCompleta = gerenciadorSessoes.sessoesDeTreinoSalvas.first(where: { $0.id == info.idSessao }) {
                                        self.sessaoSelecionada = sessaoCompleta
                                        self.mostrarDetalhe = true
                                    }
                                }
                            }
                        }
                    } else {
                        Text("").frame(maxWidth: .infinity, minHeight: 40)
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(corFundoCalendario))
        .padding(.horizontal)
    }
    
    private func mesAnterior() {
        dataAtual = Calendar.current.date(byAdding: .month, value: -1, to: dataAtual) ?? dataAtual
    }
    
    private func proximoMes() {
        dataAtual = Calendar.current.date(byAdding: .month, value: 1, to: dataAtual) ?? dataAtual
    }
    
    private func mesEAnoString(de data: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: data)
    }
    
    private func obterDiasDoMes() -> [Date?] {
        let calendario = Calendar.current
        guard let range = calendario.range(of: .day, in: .month, for: dataAtual),
              let primeiroDiaDoMes = calendario.date(from: calendario.dateComponents([.year, .month], from: dataAtual)) else { return [] }
        
        let numDias = range.count
        let primeiroDiaDaSemana = calendario.component(.weekday, from: primeiroDiaDoMes)
        var dias: [Date?] = Array(repeating: nil, count: primeiroDiaDaSemana - 1)
        
        for dia in 1...numDias {
            if let dataDoDia = calendario.date(byAdding: .day, value: dia - 1, to: primeiroDiaDoMes) { dias.append(dataDoDia) }
        }
        return dias
    }

    private func obterInfoTreino(na data: Date) -> GerenciadorSessoesViewModel.TreinoConcluidoInfo? {
        let calendario = Calendar.current
        return gerenciadorSessoes.historicoTreinosConcluidos.first { info in
            calendario.isDate(info.dataConclusao, inSameDayAs: data)
        }
    }
}

struct DiaCalendarioView: View {
    let data: Date
    let treinouNesteDia: Bool
    let corDestaque: Color
    let corTexto: Color
    
    var body: some View {
        let diaString = String(Calendar.current.component(.day, from: data))
        Text(diaString)
            .font(.system(size: 16, weight: treinouNesteDia ? .bold : .regular))
            .foregroundColor(treinouNesteDia ? .white : corTexto)
            .frame(width: 36, height: 36)
            .background(Circle().fill(treinouNesteDia ? corDestaque : Color.clear))
    }
}
