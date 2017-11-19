//
//  UserListModelTests.swift
//  PlayolaCore
//
//  Created by Brian D Keane on 8/19/17.
//  Copyright © 2017 Brian D Keane. All rights reserved.
//

import XCTest
import Quick
import Nimble

//class ListModelQuickTests: QuickSpec {
//    
//    override func spec()
//    {
//        describe("List Model Tests")
//        {
//            var dataMocker:DataMocker!
//            var dateHandlerMock:DateHandlerMock!
//            
//            beforeEach
//            {
//                dateHandlerMock = DateHandlerMock(dateAsReadableString: "2015-03-15 13:15:00")
//                dataMocker = DataMocker(DateHandler: dateHandlerMock)
//            }
//            
//            describe ("getIndex")
//            {
//                it ("gets the index of a user")
//                {
//                    var users:Array<User?> = DataMocker.generateUsers(5)
//                    let list:UserList = UserList(users: users, name: "test")
//                    let foundIndex = list.getIndex((users[3]?.id!)!)
//                    expect(foundIndex).to(equal(3))
//                }
//            }
//            
//            describe("scheduleNextAdvance")
//            {
//                it ("schedules the next advance")
//                {
//                    let users:Array<User?> = DataMocker.generateUsers(5)
//                    let list:UserList = UserList(DateHandler:dateHandlerMock, users: users, name: "test")
//                    list.scheduleNextAdvance(list.users[3]!)
//                    expect(list.users[3]?.advanceTimer!.fireDate).to(equal(users[3]?.program!.playlist![0].airtime))
//                }
//            }
//            
//            describe("addUser")
//            {
//                var users:Array<User> = Array()
//                var startingUsers:Array<User> = Array()
//                var newUsers:Array<User> = Array()
//                var list:UserList!
//                
//                beforeEach
//                {
//                    users = DataMocker.generateUsers(7) as! Array<User>
//                    startingUsers = Array(users.prefix(5))
//                    newUsers = Array(users.suffix(3))
//                    list = UserList(DateHandler: dateHandlerMock, users: startingUsers, name: "test")
//                    list.addUsers(newUsers)
//                }
//                
//                it ("adds the right number of users")
//                {
//                    expect(list.users.count).to(equal(users.count))
//                }
//                
//                it ("schedules all users properly")
//                {
//                    for user in list.users
//                    {
//                        expect(user?.advanceTimer).toNot(beNil())
//                    }
//                }
//            }
//            
//            describe("getUser functions")
//            {
//                var users:Array<User?>?
//                var list:UserList?
//                
//                beforeEach
//                {
//                    users = dataMocker.generateUsers(6)
//                    list = UserList(DateHandler: dateHandlerMock, users: users!, name: "test")
//                }
//                
//                describe ("getUser")
//                {
//                    it ("gets a user")
//                    {
//                        let gottenUser = list?.getUser((users![3]?.id!)!)
//                        expect(gottenUser!.id).to(equal(users![3]?.id))
//                    }
//                    
//                    it ("is nil if user is not found")
//                    {
//                        let gottenUser = list?.getUser("fakeID")
//                        expect(gottenUser).to(beNil())
//                    }
//                }
//                
//                describe("isInList")
//                {
//                    it ("tells if a user is in the list")
//                    {
//                        expect(list?.isInList(users![3]?.id)).to(beTrue())
//                    }
//                    
//                    it ("tells if a user is not in the list")
//                    {
//                        expect(list?.isInList("fakeID")).to(beFalse())
//                    }
//                }
//                
//                describe("refresh")
//                {
//                    it ("refreshes the list")
//                    {
//                        let user:User = users!.popLast()!!
//                        let list = UserList(DateHandler: dateHandlerMock, users: users!, name: "test3")
//                        list.refresh([user])
//                        expect(list.users.count).to(equal(1))
//                        expect(list.users[0]?.id).to(equal(user.id))
//                    }
//                }
//            }
//        }
//    }
//}
