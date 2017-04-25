//: Playground - noun: a place where people can play

import UIKit

protocol ToDoDelegate {

    func done()
}

struct ToDoItemModel {
}

extension ToDoItemModel : ToDoDelegate {

    func done() { print("Done") }
}