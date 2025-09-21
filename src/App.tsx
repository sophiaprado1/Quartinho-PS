import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import { Element } from "./screens/Element/Element";
import { EmailLogin } from "./screens/EmailLogin/EmailLogin";
import { Register } from "./screens/Register/Register";
import { UserPreference } from "./screens/UserPreference/UserPreference";

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Element />} />
        <Route path="/email-login" element={<EmailLogin />} />
        <Route path="/register" element={<Register />} />
        <Route path="/user-preference" element={<UserPreference />} />
      </Routes>
    </Router>
  );
}

export default App;