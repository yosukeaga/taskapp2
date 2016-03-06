//
//  ViewController.swift
//  taskapp2
//
//  Created by aga yosuke on 2016/03/05.
//  Copyright © 2016年 yosuke.aga. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    //try!はエラーが起こる可能性がある際に付ける
    let realm = try!Realm()
    //taskArrayは配列　object(クラス名)でクラス指定で一覧を取得、sorted:ascendingで並び替えた橋列を取得
    let taskArray = try! Realm().objects(Task).sorted("date", ascending: false)
    
    
    //入力画面がからBackしていた際のTableVeiwを更新させる
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    ///DataSourceプロトコル　tableViewのデータの数＝セルの数をreturnで返すメソッド
    func tableView(tableView:UITableView, numberOfRowsInSection section: Int) -> Int {
      return taskArray.count
         //taskArrayの配列の個数をcountプロパティで数えreturnで返す
    }
    
    
    /// 各セルの内容を返すメソッド
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        //おすすめlet cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)        
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.stringFromDate(task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("cellSegue", sender: self)
        print(self)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath)-> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            // ローカル通知をキャンセルする
            let task = taskArray[indexPath.row]
            
            for notification in UIApplication.sharedApplication().scheduledLocalNotifications! {
                if notification.userInfo!["id"] as! Int == task.id {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
                    break
                }
            }
            
            // データベースから削除する
            try! realm.write {
                         //taskArrayの配列から抜き出してdeleteしている
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
    }
    
   
    //遷移されるときに呼ばれるメソッド
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let inputViewCpntroller:InputViewController = segue.destinationViewController as!InputViewController
        
        //cellをタップしたときのパターン
        if segue.identifier == "cellSegue"{
        let indexPath = self.tableView.indexPathForSelectedRow
            print(indexPath)
            inputViewCpntroller.task = taskArray[indexPath!.row]
        }else{
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                 task.id = taskArray.max("id")! + 1
            }
            inputViewCpntroller.task = task
        }
    }
}

