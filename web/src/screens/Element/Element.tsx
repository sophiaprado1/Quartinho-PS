import { MailIcon } from "lucide-react";
import { Link } from "react-router-dom";
import { Button } from "../../components/ui/button";
import { Separator } from "../../components/ui/separator";

const socialButtons = [
  {
    icon: "/logo---google---normal.png",
    alt: "Logo google normal",
  },
  {
    icon: "/logo---facebook---normal.png",
    alt: "Logo facebook normal",
  },
];

export const Element = (): JSX.Element => {
  return (
    <div className="bg-white min-h-screen w-full flex flex-col lg:flex-row">
      {/* Left side - Hero section for desktop */}
      <div className="hidden lg:flex lg:w-1/2 bg-gradient-to-br from-orange-50 to-orange-100 items-center justify-center p-12">
        <div className="max-w-md text-center">
          <div className="relative mb-8">
            <img
              className="object-cover rounded-2xl mx-auto"
              alt="Houses collage"
              src="/frame-8.png"
            />
            <img
              className="absolute -left-8 top-4 w-24 h-32 object-cover rounded-xl"
              alt="House"
              src="/house-1--1.png"
            />
            <img
              className="absolute -right-8 -top-2 w-24 h-32 object-cover rounded-xl"
              alt="House"
              src="/house-5--1.png"
            />
            <img
              className="absolute -bottom-4 left-1/2 transform -translate-x-1/2 w-28 h-28 object-cover rounded-xl"
              alt="House"
              src="/house-2--1.png"
            />
          </div>
          <h1 className="text-4xl font-bold text-gray-800 mb-4">
            Aqui tem um
            <br />
            <span className="text-orange-500">Quartinho</span>
            <br /> pra você!
          </h1>
        </div>
      </div>

      {/* Right side - Form section */}
      <div className="flex-1 flex items-center justify-center p-6 lg:p-12">
        <div className="w-full max-w-md">
          {/* Mobile hero section */}
          <div className="lg:hidden text-center mb-12">
            <div className="relative mb-8 flex justify-center">
              <img
                className="w-72 h-48 object-cover rounded-2xl"
                alt="Frame"
                src="/frame-8.png"
              />
              <img
                className="absolute -left-4 top-2 w-20 h-24 object-cover rounded-lg"
                alt="House"
                src="/house-1--1.png"
              />
              <img
                className="absolute -right-4 -top-1 w-20 h-24 object-cover rounded-lg"
                alt="House"
                src="/house-5--1.png"
              />
              <img
                className="absolute -bottom-2 left-1/2 transform -translate-x-1/2 w-24 h-24 object-cover rounded-lg"
                alt="House"
                src="/house-2--1.png"
              />
            </div>
          </div>

          {/* Main heading */}
          <div className="text-center lg:text-left mb-8">
            <h2 className="text-2xl lg:text-3xl font-medium text-black mb-2">
              Procurando
              <br />
              um Quartinho?
            </h2>
            <p className="text-gray-600 hidden lg:block">
              Entre com seu e-mail para começar sua busca
            </p>
          </div>

          {/* Email button */}
          <Link to="/email-login">
            <Button className="w-full bg-orange-500 hover:bg-orange-600 rounded-full h-16 mb-8 transition-colors duration-200">
              <MailIcon className="w-5 h-5 mr-3" />
              <span className="font-bold text-white text-base">
                Continuar com e-mail
              </span>
            </Button>
          </Link>

          {/* Social login section */}
          <div className="space-y-6">
            <div className="relative">
              <Separator className="absolute w-full top-1/2 transform -translate-y-1/2" />
              <div className="relative flex justify-center">
                <div className="bg-white px-4 py-2">
                  <span className="text-xs font-semibold text-gray-400 tracking-wider">
                    OU
                  </span>
                </div>
              </div>
            </div>

            <div className="flex gap-4">
              {socialButtons.map((social, index) => (
                <Button
                  key={index}
                  variant="secondary"
                  className="flex-1 h-14 bg-gray-50 hover:bg-gray-100 rounded-full border border-gray-200 transition-colors duration-200"
                >
                  <img
                    className="w-6 h-6"
                    alt={social.alt}
                    src={social.icon}
                  />
                </Button>
              ))}
            </div>
          </div>

          {/* Footer */}
          <div className="text-center mt-12">
            <p className="text-sm text-gray-600">
              Não tem uma conta?{" "}
              <Link to="/register" className="font-bold text-gray-700 hover:text-orange-500 transition-colors duration-200">
                Cadastre-se!
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};