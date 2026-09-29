import Foundation

struct Product: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var cost: Double
    var price: Double
    var prepTime: Double
    var category: String
    var isAvailable: Bool = true

    init(name: String, cost: Double, price: Double, prepTime: Double, category: String = "Beverages") {
        self.id = UUID()
        self.name = name
        self.cost = cost
        self.price = price
        self.prepTime = prepTime
        self.category = category
    }
}

struct Employee: Identifiable, Codable {
    let id: UUID
    var name: String
    var role: String
    var salary: Double
    var skill: Double
    var happiness: Double
    var experience: Double
    var level: Int
    var ordersServed: Int = 0

    enum Role: String, CaseIterable {
        case barista = "Barista"
        case cashier = "Cashier"
        case cook = "Cook"
        case manager = "Manager"
        case executive = "Executive"

        var baseSalary: Double {
            switch self {
            case .barista: return 18.0
            case .cashier: return 17.0
            case .cook: return 22.0
            case .manager: return 35.0
            case .executive: return 65.0
            }
        }
    }

    init(name: String, role: String, salary: Double) {
        self.id = UUID()
        self.name = name
        self.role = role
        self.salary = salary
        self.skill = Double.random(in: 0.5...1.0)
        self.happiness = Double.random(in: 0.6...0.95)
        self.experience = 0.0
        self.level = 1
    }
}

struct InventoryItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var quantity: Int
    var maxCapacity: Int
    var cost: Double
    var reorderPoint: Int

    init(name: String, quantity: Int, maxCapacity: Int, cost: Double, reorderPoint: Int = 10) {
        self.id = UUID()
        self.name = name
        self.quantity = quantity
        self.maxCapacity = maxCapacity
        self.cost = cost
        self.reorderPoint = reorderPoint
    }
}

struct Stock: Identifiable, Codable {
    let id: UUID
    var symbol: String
    var name: String
    var currentPrice: Double
    var previousPrice: Double
    var shares: Int = 0
    var volatility: Double
    var trend: Double

    var priceChange: Double {
        currentPrice - previousPrice
    }

    var percentChange: Double {
        (priceChange / previousPrice) * 100
    }

    var isPositive: Bool {
        priceChange >= 0
    }

    init(symbol: String, name: String, price: Double, volatility: Double = 0.05) {
        self.id = UUID()
        self.symbol = symbol
        self.name = name
        self.currentPrice = price
        self.previousPrice = price
        self.volatility = volatility
        self.trend = Double.random(in: -0.02...0.02)
    }
}

struct Order: Identifiable, Codable {
    let id: UUID
    var products: [String: Int]
    var totalPrice: Double
    var status: OrderStatus
    var completedBy: String?
    var timestamp: Date

    enum OrderStatus: String, Codable {
        case pending, preparing, completed, cancelled
    }

    init(products: [String: Int], totalPrice: Double) {
        self.id = UUID()
        self.products = products
        self.totalPrice = totalPrice
        self.status = .pending
        self.timestamp = Date()
    }
}

struct BusinessDaySummary: Identifiable, Codable {
    let id: UUID
    let day: Int
    let revenue: Double
    let expenses: Double
    let profit: Double
    let ordersCompleted: Int
    let customersServed: Int

    init(day: Int, revenue: Double, expenses: Double, profit: Double, ordersCompleted: Int, customersServed: Int) {
        self.id = UUID()
        self.day = day
        self.revenue = revenue
        self.expenses = expenses
        self.profit = profit
        self.ordersCompleted = ordersCompleted
        self.customersServed = customersServed
    }
}

class GameState: ObservableObject {
    @Published var cash: Double = 5000
    @Published var netWorth: Double = 5000
    @Published var reputation: Double = 55
    @Published var day: Int = 1
    @Published var storeLevel: Int = 1
    @Published var employees: [Employee]
    @Published var products: [Product]
    @Published var inventory: [String: Int]
    @Published var inventoryItems: [InventoryItem]
    @Published var dailyHistory: [BusinessDaySummary] = []
    @Published var orders: [Order] = []
    @Published var stocks: [Stock]
    @Published var dailyRevenue: Double = 0
    @Published var dailyExpenses: Double = 0
    @Published var isPaused: Bool = false
    @Published var gameSpeed: Double = 1.0
    @Published var autoWorkEnabled: Bool = true
    @Published var totalOrdersCompleted: Int = 0
    @Published var totalCustomersServed: Int = 0

    private var gameTimer: Timer?

    init() {
        self.products = [
            Product(name: "Espresso", cost: 1.20, price: 4.50, prepTime: 1.0, category: "Beverages"),
            Product(name: "Latte", cost: 2.10, price: 6.00, prepTime: 2.0, category: "Beverages"),
            Product(name: "Cappuccino", cost: 2.30, price: 6.50, prepTime: 2.0, category: "Beverages"),
            Product(name: "Americano", cost: 1.50, price: 4.00, prepTime: 1.5, category: "Beverages"),
            Product(name: "Macchiato", cost: 2.40, price: 6.00, prepTime: 2.0, category: "Beverages"),
            Product(name: "Croissant", cost: 1.50, price: 4.00, prepTime: 1.5, category: "Pastries"),
            Product(name: "Blueberry Muffin", cost: 1.20, price: 3.50, prepTime: 1.0, category: "Pastries"),
            Product(name: "Chocolate Cake", cost: 2.00, price: 5.00, prepTime: 1.5, category: "Pastries"),
            Product(name: "Tea", cost: 0.90, price: 3.50, prepTime: 1.0, category: "Beverages"),
            Product(name: "Sandwich", cost: 3.50, price: 8.00, prepTime: 3.0, category: "Food")
        ]

        self.employees = [
            Employee(name: "Alex", role: Employee.Role.barista.rawValue, salary: 18.00),
            Employee(name: "Sam", role: Employee.Role.cashier.rawValue, salary: 17.00)
        ]

        self.inventoryItems = [
            InventoryItem(name: "Coffee Beans", quantity: 50, maxCapacity: 100, cost: 5.00),
            InventoryItem(name: "Milk", quantity: 30, maxCapacity: 50, cost: 2.50),
            InventoryItem(name: "Sugar", quantity: 40, maxCapacity: 80, cost: 1.50),
            InventoryItem(name: "Flour", quantity: 35, maxCapacity: 70, cost: 3.00),
            InventoryItem(name: "Butter", quantity: 20, maxCapacity: 40, cost: 4.00),
            InventoryItem(name: "Eggs", quantity: 60, maxCapacity: 100, cost: 0.50),
            InventoryItem(name: "Tea Leaves", quantity: 25, maxCapacity: 50, cost: 3.50)
        ]

        self.inventory = [
            "Espresso": 30,
            "Latte": 25,
            "Cappuccino": 25,
            "Americano": 20,
            "Macchiato": 20,
            "Croissant": 40,
            "Blueberry Muffin": 35,
            "Chocolate Cake": 15,
            "Tea": 35,
            "Sandwich": 10
        ]

        self.stocks = [
            Stock(symbol: "BREW", name: "BrewCorp", price: 45.50, volatility: 0.08),
            Stock(symbol: "CAFFEINE", name: "Caffeine Inc", price: 32.00, volatility: 0.06),
            Stock(symbol: "BEAN", name: "Bean Traders", price: 28.75, volatility: 0.07),
            Stock(symbol: "FOOD", name: "Food Industries", price: 55.25, volatility: 0.05),
            Stock(symbol: "RETAIL", name: "Retail Corp", price: 40.00, volatility: 0.06),
            Stock(symbol: "TECH", name: "Tech Solutions", price: 125.50, volatility: 0.10)
        ]

        dailyHistory = [
            BusinessDaySummary(day: 1, revenue: 0, expenses: 0, profit: 0, ordersCompleted: 0, customersServed: 0)
        ]

        startAutoWork()
    }

    func startAutoWork() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 2.0 / gameSpeed, repeats: true) { [weak self] _ in
            if self?.autoWorkEnabled == true && self?.isPaused == false {
                self?.serveRandomCustomer()
                self?.updateStockPrices()
            }
        }
    }

    func pauseGame() {
        isPaused.toggle()
    }

    func setGameSpeed(_ speed: Double) {
        gameSpeed = speed
        gameTimer?.invalidate()
        startAutoWork()
    }

    func serveRandomCustomer() {
        let numItems = Int.random(in: 1...3)
        var order: [String: Int] = [:]
        var totalCost: Double = 0

        for _ in 0..<numItems {
            if let product = products.randomElement() {
                let qty = Int.random(in: 1...2)
                order[product.name, default: 0] += qty

                if inventory[product.name, default: 0] >= qty {
                    inventory[product.name, default: 0] -= qty
                    totalCost += product.price * Double(qty)
                } else {
                    return
                }
            }
        }

        if !order.isEmpty {
            let newOrder = Order(products: order, totalPrice: totalCost)
            orders.append(newOrder)

            cash += totalCost
            netWorth += totalCost
            dailyRevenue += totalCost
            reputation += 0.3
            totalCustomersServed += 1

            if let randomEmployee = employees.randomElement() {
                var updatedEmployee = randomEmployee
                updatedEmployee.ordersServed += 1
                updatedEmployee.experience += 0.5
                updatedEmployee.happiness = min(1.0, updatedEmployee.happiness + 0.01)

                if let index = employees.firstIndex(where: { $0.id == randomEmployee.id }) {
                    employees[index] = updatedEmployee
                }
            }

            completeOrder(newOrder)
        }
    }

    func completeOrder(_ order: Order) {
        if let index = orders.firstIndex(where: { $0.id == order.id }) {
            var completedOrder = orders[index]
            completedOrder.status = .completed
            completedOrder.completedBy = employees.randomElement()?.name ?? "Staff"
            orders[index] = completedOrder
            totalOrdersCompleted += 1
        }
    }

    func nextDay() {
        day += 1

        let wages = employees.reduce(0.0) { $0 + $1.salary }
        dailyExpenses += wages
        cash -= wages
        netWorth -= wages

        let operational = Double(storeLevel * 120) + 50
        dailyExpenses += operational
        cash -= operational
        netWorth -= operational

        let profit = dailyRevenue - dailyExpenses

        dailyHistory.append(BusinessDaySummary(
            day: day,
            revenue: dailyRevenue,
            expenses: dailyExpenses,
            profit: profit,
            ordersCompleted: totalOrdersCompleted,
            customersServed: totalCustomersServed
        ))

        if profit > 0 {
            reputation += 2.0
        } else {
            reputation -= 1.5
        }

        reputation = min(100, max(0, reputation))
        orders.removeAll()
        dailyRevenue = 0
        dailyExpenses = 0
        totalOrdersCompleted = 0
        totalCustomersServed = 0

        updateStockPrices()
    }

    func updateStockPrices() {
        for i in 0..<stocks.count {
            let change = stocks[i].trend + Double.random(in: -stocks[i].volatility...stocks[i].volatility)
            stocks[i].previousPrice = stocks[i].currentPrice
            stocks[i].currentPrice *= (1 + change)
            stocks[i].currentPrice = max(1, stocks[i].currentPrice)
            stocks[i].trend = change * 0.7 + Double.random(in: -0.01...0.01)
        }
    }

    func buyStock(_ stock: Stock, shares: Int) {
        let cost = stock.currentPrice * Double(shares)
        if cash >= cost {
            cash -= cost
            netWorth -= cost

            if let index = stocks.firstIndex(where: { $0.id == stock.id }) {
                stocks[index].shares += shares
            }
        }
    }

    func sellStock(_ stock: Stock, shares: Int) {
        if let index = stocks.firstIndex(where: { $0.id == stock.id }), stocks[index].shares >= shares {
            let revenue = stock.currentPrice * Double(shares)
            cash += revenue
            netWorth += revenue
            stocks[index].shares -= shares
        }
    }

    func promoteEmployee(_ employee: Employee) {
        if let index = employees.firstIndex(where: { $0.id == employee.id }) {
            var updatedEmployee = employees[index]
            updatedEmployee.level += 1
            updatedEmployee.salary *= 1.2
            updatedEmployee.skill = min(1.0, updatedEmployee.skill + 0.1)
            updatedEmployee.happiness = min(1.0, updatedEmployee.happiness + 0.2)
            employees[index] = updatedEmployee
        }
    }

    func demoteEmployee(_ employee: Employee) {
        if let index = employees.firstIndex(where: { $0.id == employee.id }), employees[index].level > 1 {
            var updatedEmployee = employees[index]
            updatedEmployee.level -= 1
            updatedEmployee.salary *= 0.85
            updatedEmployee.happiness = max(0, updatedEmployee.happiness - 0.2)
            employees[index] = updatedEmployee
        }
    }

    func fireEmployee(_ employee: Employee) {
        employees.removeAll { $0.id == employee.id }
        cash += 50
        netWorth += 50
    }

    func addProduct(_ product: Product) {
        products.append(product)
        inventory[product.name] = 0
    }

    func removeProduct(_ product: Product) {
        products.removeAll { $0.id == product.id }
        inventory.removeValue(forKey: product.name)
    }

    func restockInventory(_ item: InventoryItem) {
        let cost = Double(item.maxCapacity - item.quantity) * item.cost
        if cash >= cost {
            cash -= cost
            netWorth -= cost
            dailyExpenses += cost

            if let index = inventoryItems.firstIndex(where: { $0.id == item.id }) {
                inventoryItems[index].quantity = inventoryItems[index].maxCapacity
            }
        }
    }

    func buySupplies() {
        let cost = 180.0
        if cash >= cost {
            cash -= cost
            netWorth -= cost
            dailyExpenses += cost

            for i in 0..<inventoryItems.count {
                inventoryItems[i].quantity = min(
                    inventoryItems[i].maxCapacity,
                    inventoryItems[i].quantity + Int.random(in: 10...20)
                )
            }
        }
    }

    func hireEmployee() {
        let roles = Employee.Role.allCases
        let selectedRole = roles.randomElement() ?? .barista
        let newEmployee = Employee(
            name: randomName(),
            role: selectedRole.rawValue,
            salary: selectedRole.baseSalary
        )

        let hiringCost = 150.0
        if cash >= hiringCost {
            cash -= hiringCost
            netWorth -= hiringCost
            employees.append(newEmployee)
        }
    }

    func upgradeStore() {
        let upgradeCost = Double(storeLevel * 500 + 250)
        if cash >= upgradeCost {
            cash -= upgradeCost
            netWorth -= upgradeCost
            storeLevel += 1
            reputation += 8
        }
    }

    private func randomName() -> String {
        let names = ["Jordan", "Morgan", "Taylor", "Casey", "Parker", "Jamie", "Riley", "Avery", "Alex", "Jordan", "Sam", "Chris"]
        return names.randomElement() ?? "Employee"
    }

    deinit {
        gameTimer?.invalidate()
    }
}
