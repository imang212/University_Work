using Studijni_System.App;

namespace Studijni_System.Tests;

[TestFixture]
public class Tests {
    [Test]
    public void FactoryMethod_CorrectUserTypes() {
        var student = UserFactory.CreateUser("student", "Karel");
        var teacher = UserFactory.CreateUser("ucitel", "Petr");
        Assert.That(student, Is.TypeOf<Student>(), "Factory musí vytvořit instanci Student.");
        Assert.That(student.Role, Is.EqualTo("Student"));    
        Assert.That(teacher, Is.TypeOf<Teacher>(), "Factory musí vytvořit instanci Teacher.");
        Assert.That(teacher.Role, Is.EqualTo("Učitel"));
    }
    [Test]
    public void Observer_ShouldNotifyEnrolledStudents() {
        var course = new Course("Matematika");
        var student = new Student("Jana");    
        course.Attach(student);
        course.Notify("Test zítra zrušen");
        Assert.That(student.Notifications.Count, Is.EqualTo(1), "Student by měl obdržet jedno oznámení.");
        Assert.That(student.Notifications[0], Does.Contain("zrušen"), "Text oznámení musí odpovídat zprávě.");
    }
    [Test]
    public void Strategy_ShouldCalculateAveragesCorrectly() {
        var student = new Student("Martin");
        student.Grades.Add(new Grade(1, weight: 2)); 
        student.Grades.Add(new Grade(3, weight: 1)); 
        // Aritmetický průměr: (1 + 3) / 2 = 2.0
        student.GradingStrategy = new ArithmeticAverageStrategy();
        Assert.That(student.GetCurrentAverage(), Is.EqualTo(2.0));
        // Vážený průměr: (1*2 + 3*1) / 3 = 5 / 3 = 1.666...
        student.GradingStrategy = new WeightedAverageStrategy();
        Assert.That(student.GetCurrentAverage(), Is.EqualTo(5.0 / 3.0).Within(0.01));
    }
}
