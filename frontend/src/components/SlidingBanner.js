import React, { useState, useEffect } from "react";
import { motion } from "framer-motion";
import "./SlidingBanner.css"; // Import CSS file for styling

const companies = ["AMD", "ARM", "Google", "Apple"];

const SlidingBanner = () => {
  const [offset, setOffset] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setOffset((prevOffset) =>
        prevOffset <= -100 * companies.length ? 0 : prevOffset - 1,
      );
    }, 50); // Adjust speed as needed

    return () => clearInterval(interval);
  }, []);

  return (
    <div className="slider-container">
      <div
        className="slide-container"
        style={{ transform: `translateX(${offset}%)` }}
      >
        {companies.map((company, index) => (
          <motion.div key={index} className="slide">
            <h2>
              Trusted by <span className="company-name">{company}</span>
            </h2>
          </motion.div>
        ))}
        {companies.map((company, index) => (
          <motion.div key={index + companies.length} className="slide">
            <h2>
              Trusted by <span className="company-name">{company}</span>
            </h2>
          </motion.div>
        ))}
      </div>
    </div>
  );
};

export default SlidingBanner;
