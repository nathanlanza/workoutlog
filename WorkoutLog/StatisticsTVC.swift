import UIKit
import CoreData

class StatisticsTVC: UITableViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        try! frc?.performFetch()
        tableView.reloadData()
    }

    let context = CoreData.shared.context
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = OuterTableView(frame: CGRect(), style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self , forCellReuseIdentifier: "cell")
        
        let request = WorkoutLift.request
        request.fetchBatchSize = 10
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true), NSSortDescriptor(key: "workout.date", ascending: true)]
        frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "name", cacheName: nil)
        do {
            try frc?.performFetch()
        } catch {
            print(error: error)
        }
    }
    
    var frc: NSFetchedResultsController<WorkoutLift>?
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frc?.sections?.count ?? 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let lifts = frc?.sections?[indexPath.row]
        cell.textLabel?.text = (lifts?.name)! + " x \((lifts?.numberOfObjects)!)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let lifts = frc?.sections?[indexPath.row].objects as! [WorkoutLift]
        for lift in lifts {
            print(lift.name)
        }
        let olsvc = OneLiftStatisticsVC()
        olsvc.lifts = lifts
        navigationController?.pushViewController(olsvc, animated: true)
    }
}

class OneLiftStatisticsVC: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        dateFormatter.dateFormat = "MMM d, H:mm a"
    }
    let dateFormatter = DateFormatter()
    var lifts: [WorkoutLift]!
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lifts.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let sets = lifts[indexPath.row].sets?.array as! [WorkoutSet]
        cell.textLabel?.text = sets.map { "\($0.completedWeight) x \($0.completedReps)" }.joined(separator: ", ")
        cell.detailTextLabel?.text = dateFormatter.string(from: lifts[indexPath.row].date)
        return cell
    }
    
}
