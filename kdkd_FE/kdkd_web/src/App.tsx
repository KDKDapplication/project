import { useEffect, useState } from "react";
import "./App.css";
import ChildSection from "./components/ChildSection";
import DownloadSection from "./components/DownloadSection";
import FeatureShowcase from "./components/FeatureShowcase";
import Hero from "./components/Hero";
import ParentSection from "./components/ParentSection";
type Meta = {
  buildNumber: number;
  versionName: string;
  versionCode: number;
  fileName: string;
  sha256: string;
  size: number;
  url: string;
  latestUrl: string;
  uploadedAt: string;
};

export default function DownloadPage() {
  const [meta, setMeta] = useState<Meta | null>(null);
  const [isMobile, setIsMobile] = useState(false);

  useEffect(() => {
    fetch("/downloads/metadata.json", { cache: "no-store" })
      .then((r) => (r.ok ? r.json() : Promise.reject()))
      .then(setMeta)
      .catch(() => setMeta(null));
  }, []);

  useEffect(() => {
    const checkMobile = () => {
      setIsMobile(window.innerWidth <= 768);
    };

    checkMobile();
    window.addEventListener("resize", checkMobile);

    return () => window.removeEventListener("resize", checkMobile);
  }, []);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add("show");
          }
        });
      },
      { threshold: 0.1 }
    );

    const elements = document.querySelectorAll(".fade-up");
    elements.forEach((el) => observer.observe(el));

    return () => {
      elements.forEach((el) => observer.unobserve(el));
    };
  }, []);

  const href =
    meta?.latestUrl ?? "https://j13e106.p.ssafy.io/downloads/app-latest.apk";

  return (
    <>
      <Hero isMobile={isMobile} />
      <DownloadSection isMobile={isMobile} href={href} />
      <FeatureShowcase isMobile={isMobile} />
      <ParentSection isMobile={isMobile} />
      <ChildSection isMobile={isMobile} />
    </>
  );
}
