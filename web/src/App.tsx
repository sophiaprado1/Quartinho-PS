import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import { Element } from "./screens/Element/Element";
import { EmailLogin } from "./screens/EmailLogin/EmailLogin";
import { Register } from "./screens/Register/Register";
import { UserPreference } from "./screens/UserPreference/UserPreference";
import AddProperty from "./screens/AddProperty/AddProperty";
import { Properties } from "./screens/Properties/Properties";

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Element />} />
        <Route path="/email-login" element={<EmailLogin />} />
        <Route path="/register" element={<Register />} />
        <Route path="/user-preference" element={<UserPreference />} />
        <Route path="/add-property" element={<AddProperty />} />
        <Route path="/properties" element={<Properties />} />
      </Routes>
    </Router>
  );
}

export default App;