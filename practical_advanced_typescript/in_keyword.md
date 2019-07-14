*in keyword* The `in` keyword lets us check if a certain property exists on an object. If we use it with a conditional, the compiler can make inferences  based on it:

```
interface Admin {
  id: string;
  role: string:
}
interface User {
  email: string;
}


function redirect(usr: Admin | User) {
  if("role" in usr) {
    routeToAdminPage(usr.role); // compiler knows usr is an Admin!
  } else {
    routeToHomePage(usr.email); // usr us a User!
  }
}
```