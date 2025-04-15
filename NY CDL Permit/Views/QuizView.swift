//
//  QuizView.swift
//  NY CDL Permit
//
//  Created by PDA-Jacky on 4/12/25.
//

import SwiftUI
import FirebaseFirestore

struct QuizQuestion: Identifiable {
    var id = UUID()
    var question: String
    var options: [String: String]
    var answer: String
    var explanation: String
    var reference: String
}

struct QuizView: View {
    
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    
    @State private var questions: [QuizQuestion] = []
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswers: [String?] = []
    @State private var showingResults = false
    
    private let selectedLanguage = LocalizationManager.shared.currentLanguage
    @State private var lastInteraction = Date()
    
    var body: some View {
        ZStack {
            Image("bj").resizable().scaledToFill().edgesIgnoringSafeArea(.all)
            
            VStack {
                if questions.isEmpty {
                    ProgressView(localized("loading"))
                        .onAppear { loadQuestions() }
                } else if showingResults {
                    resultView
                } else {
                    questionView
                }
            }
            .padding(.top, 10)
            
            //底部版权声明
            VStack {
                Spacer()
                Text(localized("poweredByPDA"))
                    .font(.footnote).foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 15).padding(.horizontal)
            }
        }
        .onTapGesture { lastInteraction = Date() }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
            if Date().timeIntervalSince(lastInteraction) > 1200 {
                appState.isLoggedIn = false  //自动退出
            }
        }
        .overlay(alignment: .topLeading){
            Button(action: { appState.isLoggedIn = false }) {
                Image(systemName: "arrow.backward.circle.fill")
                    .font(.largeTitle).foregroundColor(.white)
                    .padding(.leading, 20).padding(.top, 30)
            }
        }
    }
    
    /* -------- 加载题目函数 -------- */
    private func loadQuestions() {
        let collectionNames = subjects(for: appState.prefix).map {
            $0.replacingOccurrences(of: "_en", with: "_\(selectedLanguage.contains("zh") ? "zh" : selectedLanguage)")
        }

        let db = Firestore.firestore()
        questions = []

        for collectionName in collectionNames {
            db.collection(collectionName).getDocuments { snapshot, _ in
                guard let docs = snapshot?.documents else { return }
                let fetchedQuestions = docs.compactMap { doc -> QuizQuestion? in
                    let data = doc.data()
                    guard let qText = data["question"] as? String,
                          let opts = data["options"] as? [String: String],
                          let ans = data["answer"] as? String else { return nil }
                    return QuizQuestion(question: qText, options: opts, answer: ans,
                                        explanation: data["explanation"] as? String ?? "",
                                        reference: data["reference"] as? String ?? "")
                }
                DispatchQueue.main.async {
                    questions.append(contentsOf: fetchedQuestions.shuffled().prefix(20))
                    selectedAnswers = Array(repeating: nil, count: questions.count)
                }
            }
        }
    }
    
    private func subjects(for prefix: String) -> [String] {
        switch prefix {
        case "A-": return ["core_en", "airbrake_en", "combination_en"]
        case "BP-": return ["core_en", "airbrake_en", "passenger_en"]
        case "BPS-": return ["core_en", "airbrake_en", "passenger_en", "schoolbus_en"]
        default: return ["core_en"]
        }
    }

    /* -------- 显示题目视图 -------- */
    private var questionView: some View {
        VStack(spacing:20) {
            let current = questions[currentQuestionIndex]
            Text(current.question).font(.headline).foregroundColor(.white)

            ForEach(Array(current.options.keys.sorted()), id: \.self){key in
                Button(action:{selectAnswer(key)}){
                    Text("\(key). \(current.options[key]!)")
                        .padding().frame(maxWidth:.infinity)
                        .background(Color.white).foregroundColor(.black).cornerRadius(8)
                }
            }
            
            Spacer()

            Button(action:nextQuestion){
                Text(currentQuestionIndex<questions.count-1 ? localized("next") : localized("finish"))
                    .padding().frame(maxWidth: .infinity).background(Color.blue)
                    .cornerRadius(9).foregroundColor(.white)
            }
        }.padding()
    }
    
    /* -------- 显示结果视图 -------- */
    private var resultView: some View {
        VStack(spacing:15){
            Text(localized("resultTitle")).font(.largeTitle).bold().foregroundColor(.white)
            Text("\(localized("yourScore")): \(correctCount)/\(questions.count)").foregroundColor(.white)
            Text("\(percentScore)% - \(percentScore >= 80 ? localized("pass") : localized("fail"))")
                .foregroundColor(percentScore >= 80 ? .green:.red)

            Button(action:{resetQuiz()}){
                Text(localized("tryAgain")).padding().background(Color.blue).cornerRadius(10).foregroundColor(.white)
            }

            Button("⏏️ \(localized("exit"))") { appState.isLoggedIn=false }
                .padding().background(Color.red).foregroundColor(.white).cornerRadius(10)

            Spacer()
        }.padding()
    }
    
    private var correctCount: Int {
        zip(questions,selectedAnswers).reduce(0){$0 + (($1.1==$1.0.answer) ? 1:0)}
    }
    
    private var percentScore:Int{
        guard !questions.isEmpty else { return 0 }
        return Int(Double(correctCount)/Double(questions.count)*100)
    }
    
    /* -------- 功能方法 -------- */
    private func selectAnswer(_ ans:String){
        selectedAnswers[currentQuestionIndex] = ans
    }

    private func nextQuestion(){
        if currentQuestionIndex<questions.count-1{currentQuestionIndex+=1}else{showingResults=true}
    }

    private func resetQuiz(){
        selectedAnswers=Array(repeating:nil,count:questions.count)
        currentQuestionIndex=0;showingResults=false
    }

    private func localized(_ key:String)->String{
        LocalizationManager.shared.localizedString(key)
    }
}

#Preview {
    QuizView().environmentObject(AppState())
}
