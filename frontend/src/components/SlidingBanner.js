import React, { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import "./SlidingBanner.css"; // Import CSS file for styling

const companies = ["AMD", "ARM", "Google", "Apple"];

const SlidingBanner = () => {
  const [index, setIndex] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setIndex((prevIndex) => (prevIndex === companies.length - 1 ? 0 : prevIndex + 1));
    }, 3000); // Change slides every 3 seconds

    return () => clearInterval(interval);
  }, []);

  const variants = {
    enter: (direction) => {
      return {
        x: direction > 0 ? 1000 : -1000,
        opacity: 0,
      };
    },
    center: {
      zIndex: 1,
      x: 0,
      opacity: 1,
    },
    exit: (direction) => {
      return {
        zIndex: 0,
        x: direction < 0 ? 1000 : -1000,
        opacity: 0,
      };
    },
  };

  return (
    <div className="slider-container">
      <AnimatePresence initial={false} custom={1}>
        <motion.div
          key={index}
          custom={index}
          variants={variants}
          initial="enter"
          animate="center"
          exit="exit"
          transition={{ x: { type: "spring", stiffness: 300, damping: 30 }, opacity: { duration: 0.2 } }}
          className="slide"
        >
          <h2>Trusted by <span className="company-name">{companies[index]}</span></h2>
        </motion.div>
      </AnimatePresence>
    </div>
  );
};

export default SlidingBanner;
