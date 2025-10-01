import Lottie from "lottie-react";
import { useRef } from "react";
import downloadAnimation from "../assets/Download and Open morphing animation.json";
import financeAnimation from "../assets/Finance.json";

interface DownloadSectionProps {
  isMobile: boolean;
  href: string;
}

export default function DownloadSection({ isMobile, href }: DownloadSectionProps) {
  const downloadTextRef = useRef<HTMLParagraphElement>(null);

  return (
    <section
      style={{
        maxWidth: 1200,
        margin: "0 auto",
        padding: "500px 1rem 2rem",
        textAlign: "center",
        backgroundColor: "white",
      }}
    >
      <a
        href={href}
        download
        type="application/vnd.android.package-archive"
        style={{
          display: "inline-block",
          textDecoration: "none",
        }}
      >
        <Lottie
          animationData={downloadAnimation}
          loop={true}
          autoplay={true}
          style={{ width: 300, height: 300 }}
        />
      </a>
      <p
        ref={downloadTextRef}
        className="fade-up"
        style={{
          marginBottom: "650px",
          fontSize: isMobile ? "14px" : "16px",
          letterSpacing: "-0.5px",
        }}
      >
        앱을 다운로드 해보세요!
      </p>

      <div
        style={{
          maxWidth: 1200,
          margin: "0 auto",
          padding: "0 1rem",
          display: "flex",
          marginBottom: "5rem",
          flexDirection: "column",
          alignItems: "center",
        }}
      >
        <Lottie
          className="fade-up"
          animationData={financeAnimation}
          loop={true}
          autoplay={true}
          style={{ width: 400, height: 400 }}
        />
        <p
          className="fade-up"
          style={{
            fontSize: isMobile ? "16px" : "24px",
            color: "#333",
            lineHeight: 1.6,
            letterSpacing: "-1px",
            marginBottom: "650px",
          }}
        >
          키득키득 프로젝트는 부모와 자녀가 함께 <br />
          금융 습관을 만들 수 있는 금융앱 입니다.
        </p>
      </div>
    </section>
  );
}