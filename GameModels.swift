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

struct Employee: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var role: String
    var salary: Double
    var skill: Double
    var happiness: Double
    var experience: Double
    var level: Int
    var ordersServed: Int = 0

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

struct InventoryItem: Identifiable, Hashable, Codable {
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

struct Stock: Identifiable, Hashable, Codable {
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
    var items: [String: Int]
    var totalPrice: Double
    var status: String
    var createdAt: Date

    init(items: [String: Int], totalPrice: Double) {
        self.id = UUID()
        self.items = items
        self.totalPrice = totalPrice
        self.status = "Pending"
        self.createdAt = Date()
    }
}

struct DailySummary: Identifiable, Codable {
    let id: UUID
    var day: Int
    var revenue: Double
    var expenses: Double
    var profit: Double
    var ordersCompleted: Int
    var customersServed: Int

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
    @Published var reputation: Double = 60
    @Published var day: Int = 1
    @Published var storeLevel: Int = 1
    @Published var employees: [Employee]
    @Published var products: [Product]
    @Published var inventory: [String: Int]
    @Published var inventoryItems: [InventoryItem]
    @Published var orders: [Order]
    @Published var stocks: [Stock]
    @Published var history: [DailySummary]
    @Published var dailyRevenue: Double = 0
    @Published var dailyExpenses: Double = 0
    @Published var totalCustomersServed: Int = 0
    @Published var totalOrdersCompleted: Int = 0
    @Published var autoWorkEnabled: Bool = true
    @Published var isPaused: Bool = false

    private var timer: Timer?

    init() {
        self.products = [
            Product(name: "Espresso", cost: 1.20, price: 4.50, prepTime: 1.0, category: "Beverage"),
            Product(name: "Latte", cost: 2.10, price: 6.00, prepTime: 2.0, category: "Beverage"),
            Product(name: "Cappuccino", cost: 2.30, price: 6.50, prepTime: 2.0, category: "Beverage"),
            Product(name: "Tea", cost: 0.90, price: 3.50, prepTime: 1.0, category: "Beverage"),
            Product(name: "Croissant", cost: 1.50, price: 4.00, prepTime: 1.5, category: "Food"),
            Product(name: "Muffin", cost: 1.20, price: 3.50, prepTime: 1.0, category: "Food"),
            Product(name: "Sandwich", cost: 2.80, price: 7.50, prepTime: 2.5, category: "Food")
        ]

        self.employees = [
            Employee(name: "Alex", role: "Barista", salary: 18.0),
            Employee(name: "Sam", role: "Cashier", salary: 17.0)
        ]

        self.inventory = [
            "Espresso": 25,
            "Latte": 20,
            "Cappuccino": 18,
            "Tea": 30,
            "Croissant": 25,
            "Muffin": 20,
            "Sandwich": 12
        ]

        self.inventoryItems = [
            InventoryItem(name: "Coffee Beans", quantity: 45, maxCapacity: 100, cost: 3.0),
            InventoryItem(name: "Milk", quantity: 35, maxCapacity: 80, cost: 2.0),
            InventoryItem(name: "Sugar", quantity: 40, maxCapacity: 90, cost: 1.0),
            InventoryItem(name: "Flour", quantity: 30, maxCapacity: 80, cost: 1.8),
            InventoryItem(name: "Tea Leaves", quantity: 20, maxCapacity: 60, cost: 2.5)
        ]

        self.orders = []
        self.stocks = [
            Stock(symbol: "BREW", name: "BrewCo", price: 45.50),
            Stock(symbol: "BEAN", name: "BeanWorks", price: 32.10),
            Stock(symbol: "FOOD", name: "Food Industries", price: 68.00),
            Stock(symbol: "TECH", name: "TechNova", price: 120.20)
        ]

        self.history = [
            DailySummary(day: 1, revenue: 0, expenses: 0, profit: 0, ordersCompleted: 0, customersServed: 0)
        ]

        startAutoSimulation()
    }

    func startAutoSimulation() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if !self.isPaused && self.autoWorkEnabled {
                self.serveRandomOrder()
                self.updateStocks()
            }
        }
    }

    func togglePause() {
        isPaused.toggle()
    }

    func serveRandomOrder() {
        let orderSize = Int.random(in: 1...3)
        var itemDict: [String: Int] = [:]
        var total = 0.0

        for _ in 0..<orderSize {
            guard let product = products.randomElement() else { continue }
            let quantity = Int.random(in: 1...2)

            if inventory[product.name, default: 0] >= quantity {
                inventory[product.name, default: 0] -= quantity
                itemDict[product.name, default: 0] += quantity
                total += product.price * Double(quantity)
            }
        }

        guard !itemDict.isEmpty else { return }

        var newOrder = Order(items: itemDict, totalPrice: total)
        orders.append(newOrder)

        cash += total
        netWorth += total
        dailyRevenue += total
        totalCustomersServed += 1

        if let employee = employees.randomElement() {
            if let index = employees.firstIndex(where: { $0.id == employee.id }) {
                var updated = employees[index]
                updated.ordersServed += 1
                updated.experience += 0.5
                updated.happiness = min(1.0, updated.happiness + 0.02)
                employees[index] = updated
            }
        }

        totalOrdersCompleted += 1
        if let idx = orders.firstIndex(where: { $0.id == newOrder.id }) {
            orders[idx].status = "Completed"
        }
    }

    func buySupplies() {
        let cost = 180.0
        if cash >= cost {
            cash -= cost
            netWorth -= cost
            dailyExpenses += cost

            for i in 0..<inventoryItems.count {
                inventoryItems[i].quantity = min(inventoryItems[i].maxCapacity, inventoryItems[i].quantity + Int.random(in: 10...20))
            }
        }
    }

    func hireEmployee() {
        let roles = ["Barista", "Cashier", "Cook", "Manager"]
        let newEmployee = Employee(
            name: randomName(),
            role: roles.randomElement() ?? "Barista",
            salary: Double.random(in: 18...40)
        )

        if cash >= 150 {
            cash -= 150
            netWorth -= 150
            employees.append(newEmployee)
        }
    }

    func fireEmployee(_ employee: Employee) {
        employees.removeAll { $0.id == employee.id }
        cash += 50
        netWorth += 50
    }

    func promoteEmployee(_ employee: Employee) {
        if let idx = employees.firstIndex(where: { $0.id == employee.id }) {
            var updated = employees[idx]
            updated.level += 1
            updated.salary *= 1.2
            updated.skill = min(1.0, updated.skill + 0.08)
            updated.happiness = min(1.0, updated.happiness + 0.1)
            employees[idx] = updated
        }
    }

    func demoteEmployee(_ employee: Employee) {
        if let idx = employees.firstIndex(where: { $0.id == employee.id }), employees[idx].level > 1 {
            var updated = employees[idx]
            updated.level -= 1
            updated.salary *= 0.9
            updated.happiness = max(0.0, updated.happiness - 0.1)
            employees[idx] = updated
        }
    }

    func upgradeStore() {
        let cost = Double(storeLevel * 500 + 250)
        if cash >= cost {
            cash -= cost
            netWorth -= cost
            storeLevel += 1
            reputation += 8
        }
    }

    func addProduct(_ product: Product) {
        products.append(product)
        inventory[product.name] = 10
    }

    func removeProduct(_ product: Product) {
        products.removeAll { $0.id == product.id }
        inventory.removeValue(forKey: product.name)
    }

    func buyStock(_ stock: Stock, shares: Int) {
        let cost = stock.currentPrice * Double(shares)
        if cash >= cost {
            cash -= cost
            netWorth -= cost

            if let idx = stocks.firstIndex(where: { $0.id == stock.id }) {
                stocks[idx].shares += shares
            }
        }
    }

    func sellStock(_ stock: Stock, shares: Int) {
        if let idx = stocks.firstIndex(where: { $0.id == stock.id }), stocks[idx].shares >= shares {
            let revenue = stock.currentPrice * Double(shares)
            cash += revenue
            netWorth += revenue
            stocks[idx].shares -= shares
        }
    }

    func updateStocks() {
        for i in 0..<stocks.count {
            let tick = stocks[i].trend + Double.random(in: -stocks[i].volatility...stocks[i].volatility)
            stocks[i].previousPrice = stocks[i].currentPrice
            stocks[i].currentPrice = max(1.0, stocks[i].currentPrice * (1 + tick))
            stocks[i].trend = tick * 0.8
        }
    }

    func nextDay() {
        day += 1
        let wages = employees.reduce(0.0) { $0 + $1.salary }
        cash -= wages
        netWorth -= wages
        dailyExpenses += wages

        let fixedCosts = Double(storeLevel * 120 + 50)
        cash -= fixedCosts
        netWorth -= fixedCosts
        dailyExpenses += fixedCosts

        let profit = dailyRevenue - dailyExpenses

        history.append(
            DailySummary(
                day: day,
                revenue: dailyRevenue,
                expenses: dailyExpenses,
                profit: profit,
                ordersCompleted: totalOrdersCompleted,
                customersServed: totalCustomersServed
            )
        )

        if profit > 0 {
            reputation += 2
        } else {
            reputation -= 1.5
        }

        reputation = min(100, max(0, reputation))
        dailyRevenue = 0
        dailyExpenses = 0
        totalOrdersCompleted = 0
        totalCustomersServed = 0
        orders = []

        updateStocks()
    }

    func stockValue() -> Double {
        stocks.reduce(0) { $0 + Double($1.shares) * $1.currentPrice }
    }

    private func randomName() -> String {
        let names = ["Jordan", "Morgan", "Taylor", "Avery", "Jamie", "Chris", "Casey", "Parker", "Riley", "Drew"]
        return names.randomElement() ?? "Employee"
    }

    deinit {
        timer?.invalidate()
    }
}
