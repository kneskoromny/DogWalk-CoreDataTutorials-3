/// Copyright (c) 2020 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import CoreData

class ViewController: UIViewController {
  // MARK: - Properties
  lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
  }()
  lazy var coreDataStack = CoreDataStack(modelName: "DogWalk")

  var currentDog: Dog?

  // MARK: - IBOutlets
  @IBOutlet var tableView: UITableView!


  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    
    let dogName = "Fido"
    // извлекаем все объекты-собаки с именами "Fido" из Core Data
    let dogFetch: NSFetchRequest<Dog> = Dog.fetchRequest()
    dogFetch.predicate = NSPredicate(format: "%K == %@",
                                     #keyPath(Dog.name), dogName)
    do {
      let results = try coreDataStack.managedContext.fetch(dogFetch)
      if results.isEmpty {
        // Если запрос на извлечение возвращается с нулевыми результатами, это, вероятно, означает, что пользователь впервые открывает приложение. В этом случае вы вставляете новую собаку, называете ее “Фидо” и устанавливаете ее в качестве текущей выбранной собаки.
        currentDog = Dog(context: coreDataStack.managedContext)
        currentDog?.name = dogName
        coreDataStack.saveContext()
      } else {
        // Если запрос вернулся с результатами, вы устанавливаете первую сущность (должна быть только одна) в качестве текущей выбранной собаки
        currentDog = results.first
      }
    } catch let error as NSError {
      print("Fetch error: \(error) description: \(error.userInfo)")
    }
  }
}

// MARK: - IBActions
extension ViewController {
  @IBAction func add(_ sender: UIBarButtonItem) {
    // добавляем новую сущность Walk в Core Data
      let walk = Walk(context: coreDataStack.managedContext)
    // для атрибута date устанавливаем значение сейчас
      walk.date = Date()
      // добавляем новую прогулку в набор прогулок собаки
//      if let dog = currentDog,
//        // создаем изменяемую копию NSMutableOrderedset, чтобы добавить прогулку
//        let walks = dog.walks?.mutableCopy() as? NSMutableOrderedSet {
//        // добавляем
//          walks.add(walk)
//        // присваиваем значение прогулок атрибуту собаки
//          dog.walks = walks
//    }
    // заменяет все вышенаписанное if let
    currentDog?.addToWalks(walk)
      // сохраняем контекст
      coreDataStack.saveContext()
      // перезагружаем table view
      tableView.reloadData()
  }
}

// MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    currentDog?.walks?.count ?? 0
  }

  func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "Cell", for: indexPath)
    
    guard let walk = currentDog?.walks?[indexPath.row] as? Walk,
        let walkDate = walk.date as Date? else {
    return cell }
    
    cell.textLabel?.text = dateFormatter.string(from: walkDate)
    return cell
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    "List of Walks"
  }
}
