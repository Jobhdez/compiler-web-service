import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Home from "./components/Home";
import Header from "./components/Header";
import Footer from "./components/Footer";
import CServe from "./components/CServe";
import About from "./components/About";
import OpenSourceProducts from "./components/OpenSourceProducts";

function App() {
  return (
    <Router>
      <Header />
      <Routes>
        <Route exact path="/" element={<Home />} />
        <Route path="/cserve" element={<CServe />} />
        <Route path="/open source products" element={<OpenSourceProducts />} />
        <Route path="/about" element={<About />} />
      </Routes>
      <Footer />
    </Router>
  );
}

export default App;
