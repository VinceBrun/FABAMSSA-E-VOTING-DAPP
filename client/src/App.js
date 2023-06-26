import React from "react";

import "./styles/Home.css";
import Navbar from './components/navbar.js';
import Header from './components/header.js';
import Footer from './components/footer';



export default function Home() {
  return (
    <div className="container">
      <div>
        <Navbar />
      </div>
      <div>
        <Header />
      </div>
      <div>
        <Footer />
      </div>
    </div>
  );
}
