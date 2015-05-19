#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

struct Z {
  Z() { cout << "Z ctor" << endl; }
  Z(Z const&) { cout << "Z copied" << endl; }
  Z(Z&& other) {  cout << "Z moved" << endl; }
  Z& operator=(Z&& other) {  cout << "Z move assigned" << endl; return *this; }
  Z& operator=(Z const& rhs) { cout << "Z copy assigned" << endl; return *this; }
  bool operator==(Z const& rhs) const {
    return true;
  }
};

#if (false)
struct Foo {
  bool operator==(Foo const& rhs) const {
    return this == &rhs ||
           (t == rhs.t && x == rhs.x && y == rhs.y && z == rhs.z);
  }

  Foo( double t_ = 3.14 ) {
    //    cout << "y is " << y << endl;
  }

  Foo(double t_, int x_, std::string y_, Z z_) :
    t {t_}, x {x_}, y {y_}, z {z_} {}

  double t{3.14};
  int x{0};
  std::string y{"goo"};
  Z z{};
};
#else

struct Foo {


  Foo(double t_, int x_, std::string y_, Z z_) :
    t {t_}, x {x_}, y {y_}, z {z_} {}

  // Foo(Foo&& other) :
  //   t { move(other.t) },
  //   x { move(other.x) },
  //   y { move(other.y) },
  //   z { move(other.z) }
  // {
  //   cout << "Foo moved " << endl;
  // }

  Foo() = default;
  Foo(Foo const& other) = default;
  Foo(Foo other) = default;
  //Foo(Foo&& other) = default;

  //Foo& operator=(Foo const& other) = default;

  bool operator==(Foo const& rhs) const {
    return this == &rhs ||
           (t == rhs.t && x == rhs.x && y == rhs.y && z == rhs.z);
  }

  bool operator!=(Foo const& rhs) const { return !(*this == rhs); }

  double t{3.14};
  int x{0};
  std::string y{"goo"};
  Z z{};
};
#endif

int main(int argc, char **argv) {
  Foo f1;
  Foo f2 { f1 };
  cout << (f1 == f2) << endl;
  f1.x++;
  cout << (f1 == f2) << endl;
  f1.x--;
  cout << (f1 == f2) << endl;

  std::vector<Foo> foos = {
    Foo(), Foo(), Foo(),
    Foo {3.15, 2, "moo", Z{}  }
  };

  reverse(foos.begin(), foos.end());
}
