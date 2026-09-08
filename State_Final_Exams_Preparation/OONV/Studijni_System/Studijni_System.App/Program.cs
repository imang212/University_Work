using System; 
using System.Collections.Generic; 
using System.Linq;
using System.Runtime.CompilerServices;

namespace Studijni_System.App {
    // strategy - strategie pro výpočet známky
    public class Grade {
        public double Value { get; set; }
        public int Weight { get; set; }
        public Grade(double value, int weight) { Value = value; Weight = weight; }
    }
    public interface IGradingStrategy {
        double CalculateAverage(List<Grade> grades);
    }
    public class ArithmeticAverageStrategy : IGradingStrategy {
        public double CalculateAverage(List<Grade> grades) {
            if (!grades.Any()) return 0;
            return grades.Average(g => g.Value);
        }
    }
    public class WeightedAverageStrategy : IGradingStrategy {
        public double CalculateAverage(List<Grade> grades) {
            if (!grades.Any()) return 0;
            double sum = grades.Sum(g => g.Value * g.Weight);
            int total_Weight = grades.Sum(g => g.Weight);
            return sum / total_Weight; 
        }
    }
    // observer - upozornění na změny
    public interface IObserver { void Update(string message); }
    public interface ISubject { void Attach(IObserver observer); void Notify(string message); }
    public class Course : ISubject {
        public string Name { get; set; }
        private readonly List<IObserver> _students = new List<IObserver>();
        public Course(string name) { Name = name; }
        public void Attach(IObserver observer) => _students.Add(observer);
        // notify při jakékoliv změně informuje všechny přihlášené studenty
        public void Notify(string message) {
            foreach (var student in _students) student.Update($"[Kurz {Name}] {message}");            
        }
    }
    // factory method - vytváření uživatelů
    public interface IUser { string Name { get; } string Role { get; } }
    public class Student : IUser, IObserver {
        public string Name { get; set; }
        public string Role => "Student";
        public List<Grade> Grades { get; set; } = new List<Grade>();
        public IGradingStrategy GradingStrategy { get; set; }
        public List<string> Notifications { get; set; } = new List<string>();
        public Student(string name) { 
            Name = name; 
            Grades = new List<Grade>();
            GradingStrategy = new ArithmeticAverageStrategy();
            Notifications = new List<string>();   
        }
        public void Update(string message) {
            Console.WriteLine($"Právě dorazila notifikace {message}");
            Notifications.Add(message);
        }
        public double GetCurrentAverage() => GradingStrategy.CalculateAverage(Grades);
    }
    public class Teacher : IUser {
        public string Name { get; set; }
        public string Role => "Učitel";
        public Teacher(string name) { Name = name; }
    }
    public class Administrator : IUser {
        public string Name { get; set; }
        public string Role => "Správce";
        public Administrator(string name) { Name = name; }
    }
    public static class UserFactory {
        public static IUser CreateUser(string roleType, string name) {
            return roleType.ToLower() switch {
                "student" => new Student(name), "ucitel" => new Teacher(name), "spravce" => new Administrator(name),
                _ => throw new ArgumentException("Neznámý typ uživatele")
            };
        }
    }
    public static class CourseFactory {
        public static Course CreateCourse(string name) { return new Course(name); }
    }
    class Program {
        static List<IUser> Users = new List<IUser>();
        static List<Course> Courses = new List<Course>();
        static IUser CurrentUser = null;
        static void Main() {
            //Console.WriteLine("Studijní systém (Ukázka návrhových vzorů)");
            //// vytv uzivatelů pomocí factory method
            //var student = (Student)UserFactory.CreateUser("student", "Jan Novák");
            //var ucitel = UserFactory.CreateUser("ucitel", "Dr. Alena");
            //// sprava kurzu a prihlaseni
            //var kurzOON = new Course("Objektově orientovaný návrh");
            //kurzOON.Attach(student);
            //kurzOON.Attach((Student)UserFactory.CreateUser("student", "Josef Novák"));
            //// oznámení pomocí observer vzoru
            //Console.WriteLine($"Učitel {ucitel.Name} mění rozvrh...");
            //kurzOON.Notify("Přednáška je přesunuta na 14:00.");
            //Console.WriteLine($"Oznámení studenta ({student.Name})");
            //student.Notifications.ForEach(Console.WriteLine);
            //// simulace známek pomocí strategy vzoru
            //student.Grades.Add(new Grade(1, weight: 2));
            //student.Grades.Add(new Grade(3, weight: 1));
            //Console.WriteLine($"Studijní výsledky ({student.Name})");
            //Console.WriteLine($"Aritmetický průměr {student.GetCurrentAverage():F2}");
            //student.GradingStrategy = new WeightedAverageStrategy();
            //Console.WriteLine($"Vážený průměr {student.GetCurrentAverage():F2}");
            //Console.WriteLine("\nStiskněte klávesu pro ukončení...");
            //Console.ReadKey();

            Users.Add(UserFactory.CreateUser("spravce", "Admin"));
            Users.Add(UserFactory.CreateUser("ucitel", "Novak"));
            Users.Add(UserFactory.CreateUser("student", "Karel"));
            Courses.Add(CourseFactory.CreateCourse("Matematika"));
            while (true) {
                Console.Clear();
                if (CurrentUser == null) { ShowLoginMenu(); }
                else { ShowMainMenu(); }
            }
        }
        static void ShowLoginMenu() {
            Console.WriteLine("Studijní Informační Systém");
            Console.WriteLine("1. Přihlásit se");
            Console.WriteLine("2. Registrovat nového uživatele");
            Console.WriteLine("3. Ukončit aplikaci");
            Console.Write("Volba: ");
            switch (Console.ReadLine()) {
                case "1":
                    Console.Write("Zadejte vaše jméno: ");
                    string loginName = Console.ReadLine();
                    CurrentUser = Users.FirstOrDefault(u => u.Name.Equals(loginName, StringComparison.OrdinalIgnoreCase));
                    if (CurrentUser == null) {
                        Console.WriteLine("Uživatel nenalezen! Stiskněte klávesu...");
                        Console.ReadKey();
                    }
                    break;
                case "2":
                    Console.Write("Zadejte roli (student/ucitel/spravce): ");
                    string role = Console.ReadLine();
                    Console.Write("Zadejte jméno: ");
                    string name = Console.ReadLine();
                    try {
                        var newUser = UserFactory.CreateUser(role, name);
                        Users.Add(newUser);
                        Console.WriteLine("Registrace úspěšná!");
                    }
                    catch (Exception ex) { Console.WriteLine($"Chyba: {ex.Message}"); }
                    Console.ReadKey();
                    break;
                case "3":
                    Environment.Exit(0);
                    break;
            }
        }
        static void ShowMainMenu() {
            Console.WriteLine($"\nPřihlášen: {CurrentUser.Name} ({CurrentUser.Role})");
            Console.WriteLine("1. Zobrazit všechny kurzy");
            // --- Menu pro Studenta ---
            if (CurrentUser is Student student) {
                Console.WriteLine("2. Zapsat si kurz");
                Console.WriteLine("3. Zobrazit studijní výsledky a oznámení");
                Console.WriteLine("4. Odhlásit se");
                Console.Write("Volba: ");
                switch (Console.ReadLine()) {
                    case "1":
                        Courses.ForEach(c => Console.WriteLine($"- {c.Name}"));
                        break;
                    case "2":
                        Console.Write("Zadejte název kurzu pro zápis: ");
                        string courseName = Console.ReadLine();
                        var course = Courses.FirstOrDefault(c => c.Name.Equals(courseName, StringComparison.OrdinalIgnoreCase));
                        if (course != null) {
                            course.Attach(student); // Využití vzoru Observer pro sledování
                            Console.WriteLine("Zapsáno!");
                        }
                        break;
                    case "3":
                        Console.WriteLine($"\nVýsledky (Aritmetický průměr): {student.GetCurrentAverage():F2}");
                        student.GradingStrategy = new WeightedAverageStrategy(); // Využití Strategy vzoru
                        Console.WriteLine($"Výsledky (Vážený průměr): {student.GetCurrentAverage():F2}");
                        Console.WriteLine("\n--- Oznámení ---");
                        student.Notifications.ForEach(Console.WriteLine);
                        break;
                    case "4":
                        CurrentUser = null;
                        return;
                }
            }
            else
            {
                Console.WriteLine("2. Vytvořit nový kurz");
                Console.WriteLine("3. Odeslat oznámení studentům kurzu");
                Console.WriteLine("4. Přidat známku studentovi");
                Console.WriteLine("5. Odhlásit se");
                Console.Write("Volba: ");
                
                switch (Console.ReadLine())
                {
                    case "1":
                        Courses.ForEach(c => Console.WriteLine($"- {c.Name}"));
                        break;
                    case "2":
                        Console.Write("Název nového kurzu: ");
                        string newCourse = Console.ReadLine();
                        Courses.Add(CourseFactory.CreateCourse(newCourse)); // Factory Method
                        Console.WriteLine("Kurz vytvořen.");
                        break;
                    case "3":
                        Console.Write("Zadejte název kurzu: ");
                        var c = Courses.FirstOrDefault(x => x.Name == Console.ReadLine());
                        if (c != null)
                        {
                            Console.Write("Zadejte zprávu pro studenty: ");
                            c.Notify(Console.ReadLine()); // Využití Observer vzoru
                            Console.WriteLine("Odesláno!");
                        }
                        break;
                    case "4":
                        Console.Write("Zadejte jméno studenta: ");
                        var s = Users.OfType<Student>().FirstOrDefault(x => x.Name == Console.ReadLine());
                        if (s != null)
                        {
                            Console.Write("Zadejte známku (1-5): ");
                            double val = double.Parse(Console.ReadLine());
                            Console.Write("Zadejte váhu (např. 1 nebo 2): ");
                            int weight = int.Parse(Console.ReadLine());
                            s.Grades.Add(new Grade(val, weight));
                            Console.WriteLine("Známka přidána.");
                        }
                        break;
                    case "5":
                        CurrentUser = null;
                        return;
                }
            }
            Console.WriteLine("Stiskněte klávesu...");
            Console.ReadKey();
        }
    }
}
