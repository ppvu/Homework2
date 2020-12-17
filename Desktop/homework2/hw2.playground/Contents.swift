import Foundation

//I create some enums to divide access levels and some errors that I can meet in my system

enum Status {
    case regularUser,
         admin
}

//Errors that I will throw into my funcs

enum SysErrors: Error {
    case loginIsTaken,
         wrongLogin,
         wrongPass,
         accessError,
         autorizationFailed
}



//Creating a betting system class

class SpezzaBetSystem {
    
    //Creating a Dictionary that will stash all registered user in bet system
    
    var allUsers: Dictionary<String, User> = [:]
    
    //Creating a structure of users
    
    struct User {
        var password: String
        var status: Status
        var bets = [String]()
        var isBanned = false
        var isOnline = false
    }
    
    //Creating a func for registation (also checking unique of login)
    
    func addNewUser(login: String, password: String, status: Status = .regularUser) throws {
        guard allUsers[login] == nil else { throw SysErrors.loginIsTaken}
        allUsers[login] = User(password: password, status: status)
    }
    
    
    
    //Creating a func for login (checking compliance of login and password)
    
    func login(login: String, password: String) throws {
        guard var user = allUsers[login] else { throw SysErrors.wrongLogin }
        guard user.password == password else { throw SysErrors.wrongPass }
        guard !user.isBanned else { throw SysErrors.accessError }
        user.isOnline = true
        allUsers[login] = user
    }
    
    //Function logout change the user's status (online or offline). If offline - user is logged out
    
    func logout(login: String) throws {
        guard var user  = allUsers[login] else { throw SysErrors.wrongLogin}
        user.isOnline = false
        allUsers[login] = user
    }
    
    //Here is a function that allow to make a bet if a user is logged in
    
    func makeBet(login: String, bet: String) throws {
        guard var user = allUsers[login] else { throw SysErrors.wrongLogin}
        guard user.isOnline == true else { throw SysErrors.autorizationFailed }
        user.bets.append(bet)
        allUsers[login] = user
    }
    
    //Here is a function that returns the list of user's bets from Dictionary
    
    func listOfBets(login: String) throws -> [String] {
        guard let user = allUsers[login] else { throw SysErrors.wrongLogin}
        guard user.isOnline == true else { throw SysErrors.autorizationFailed }
        return user.bets
    }
    
    //Here is a function that returns the list of regular users (only for admins)
    
    func listOfUsers(login: String) throws -> Dictionary<String, User> {
        guard let user = allUsers[login] else { throw SysErrors.wrongLogin}
        guard user.status == .admin else { throw SysErrors.accessError }
        return allUsers.filter {_, user in user.status == .regularUser }
    }
    
    //This function can ban regular users (only for admins)
    
    func banForUser(loginAdmin: String, loginToBan: String) throws {
        guard let userAdmin = allUsers[loginAdmin] else { throw SysErrors.wrongLogin}
        guard var userReg = allUsers[loginToBan] else { throw SysErrors.wrongLogin}
        guard userAdmin.status == .admin else { throw SysErrors.accessError}
        guard userReg.status == .regularUser else { throw SysErrors.accessError}
        guard userAdmin.isOnline == true else { throw SysErrors.autorizationFailed}
        userReg.isBanned = true
        print("Authorization failed. You've banned")
    }
}



