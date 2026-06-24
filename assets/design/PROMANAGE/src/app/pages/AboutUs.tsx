import { ImageWithFallback } from '../components/figma/ImageWithFallback';
import { Header } from '../components/Header';
import { 
  FolderKanban, 
  CheckSquare, 
  Calendar, 
  BarChart3, 
  Lock, 
  ClipboardCheck,
  Mail,
  Phone,
  MapPin,
  Facebook,
  Twitter,
  Linkedin,
  Instagram,
  Target,
  Users,
  TrendingUp
} from 'lucide-react';

export function AboutUs() {
  const teamMembers = [
    {
      name: 'Dwi Arbi Nugroho',
      role: 'Project Concept and System Planning',
      image: 'https://images.unsplash.com/photo-1629507208649-70919ca33793?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwcm9mZXNzaW9uYWwlMjBidXNpbmVzcyUyMHBvcnRyYWl0JTIwbWFufGVufDF8fHx8MTc3Mjk5MDgzNXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
    },
    {
      name: 'Muhammad Rizki',
      role: 'System Development and Feature Design',
      image: 'https://images.unsplash.com/photo-1621388730896-b0e6b1ba5c51?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhc2lhbiUyMHByb2Zlc3Npb25hbCUyMGRldmVsb3BlciUyMHBvcnRyYWl0fGVufDF8fHx8MTc3MzAzNjI2Mnww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
    },
    {
      name: 'Robin Felix Hama',
      role: 'UI and Interface Design',
      image: 'https://images.unsplash.com/photo-1695712551846-4dc15433fbd4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHByb2Zlc3Npb25hbCUyMGRlc2lnbmVyJTIwaGVhZHNob3R8ZW58MXx8fHwxNzczMDM2MjYyfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
    },
    {
      name: 'George',
      role: 'System Testing and Evaluation',
      image: 'https://images.unsplash.com/photo-1564518534518-e79657852a1a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzb2Z0d2FyZSUyMGVuZ2luZWVyJTIwcHJvZmVzc2lvbmFsJTIwcGhvdG98ZW58MXx8fHwxNzczMDM2MjYzfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral'
    }
  ];

  const initiatives = [
    { icon: FolderKanban, title: 'Project Management', color: 'bg-blue-500' },
    { icon: CheckSquare, title: 'Task Management', color: 'bg-green-500' },
    { icon: Calendar, title: 'Activity Planning', color: 'bg-purple-500' },
    { icon: BarChart3, title: 'Project Monitoring', color: 'bg-orange-500' },
    { icon: ClipboardCheck, title: 'Project Evaluation', color: 'bg-pink-500' },
    { icon: Lock, title: 'Project Closure', color: 'bg-red-500' }
  ];

  return (
    <div className="min-h-screen bg-gradient-to-b from-white to-gray-50">
      <Header />

      {/* Hero Section */}
      <section className="px-4 py-10 sm:px-6 md:px-12 lg:px-20 md:py-16">
        <div className="max-w-7xl mx-auto text-center">
          <h2 className="text-2xl sm:text-4xl md:text-5xl font-bold text-gray-900 mb-4 md:mb-6">
            About Our Project
          </h2>
          <p className="text-sm sm:text-lg text-gray-600 max-w-3xl mx-auto leading-relaxed">
            Our platform helps manage academic and smart city related projects efficiently,
            making collaboration between teams easier. We provide comprehensive tools to
            streamline project workflows and enhance productivity.
          </p>
        </div>
      </section>

      {/* About the Project */}
      <section className="px-4 py-10 sm:px-6 md:px-12 lg:px-20 md:py-16 bg-white">
        <div className="max-w-7xl mx-auto">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8 md:gap-12 items-center">
            <div>
              <h3 className="text-2xl sm:text-3xl font-bold text-gray-900 mb-4 md:mb-6">About the Project</h3>
              <p className="text-gray-600 leading-relaxed mb-4 text-sm sm:text-base">
                Our system is designed to help teams manage projects, tasks, activities,
                and evaluations in an organized digital platform. We understand the
                challenges of coordinating multiple stakeholders and activities.
              </p>
              <p className="text-gray-600 leading-relaxed text-sm sm:text-base">
                With ProManage, you can centralize all project information, track progress
                in real-time, and ensure transparent communication across all team members.
                Our intuitive interface makes project management accessible to everyone.
              </p>
            </div>
            <div className="bg-gradient-to-br from-blue-50 to-purple-50 rounded-2xl p-6 sm:p-8">
              <div className="grid grid-cols-2 gap-4 sm:gap-6">
                {[
                  { Icon: Target, color: 'text-blue-600', title: 'Goal Oriented', desc: 'Clear project objectives' },
                  { Icon: Users, color: 'text-green-600', title: 'Team Work', desc: 'Seamless collaboration' },
                  { Icon: TrendingUp, color: 'text-purple-600', title: 'Progress Track', desc: 'Real-time monitoring' },
                  { Icon: BarChart3, color: 'text-orange-600', title: 'Analytics', desc: 'Data-driven insights' },
                ].map(({ Icon, color, title, desc }, i) => (
                  <div key={i} className="bg-white rounded-xl p-4 sm:p-6 shadow-sm">
                    <Icon className={`w-8 h-8 sm:w-10 sm:h-10 ${color} mb-3`} />
                    <h4 className="font-bold text-gray-900 mb-1 text-sm sm:text-base">{title}</h4>
                    <p className="text-xs sm:text-sm text-gray-600">{desc}</p>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Vision and Mission */}
      <section className="px-4 py-10 sm:px-6 md:px-12 lg:px-20 md:py-16">
        <div className="max-w-7xl mx-auto">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 sm:gap-8">
            <div className="bg-gradient-to-br from-red-800 to-red-900 rounded-2xl p-6 sm:p-8 text-white">
              <h3 className="text-xl sm:text-2xl font-bold mb-4">Our Vision</h3>
              <p className="leading-relaxed text-sm sm:text-base">
                Become an innovative platform that supports effective and transparent
                project management, empowering teams to achieve their goals with confidence
                and clarity.
              </p>
            </div>
            <div className="bg-white rounded-2xl p-6 sm:p-8 shadow-lg border border-gray-100">
              <h3 className="text-xl sm:text-2xl font-bold text-gray-900 mb-5">Our Mission</h3>
              <ul className="space-y-3">
                {[
                  'Provide tools to manage projects and tasks clearly',
                  'Support collaboration between team members',
                  'Help monitor project progress efficiently',
                  'Improve productivity through a simple digital system',
                ].map((text, i) => (
                  <li key={i} className="flex gap-3">
                    <CheckSquare className="w-5 h-5 text-red-800 flex-shrink-0 mt-0.5" />
                    <span className="text-gray-600 text-sm sm:text-base">{text}</span>
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* Team Members */}
      <section className="px-4 py-10 sm:px-6 md:px-12 lg:px-20 md:py-16 bg-white">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-10 md:mb-12">
            <h3 className="text-2xl sm:text-3xl md:text-4xl font-bold text-gray-900 mb-3">Our Team</h3>
            <p className="text-sm sm:text-lg text-gray-600">Meet the people behind ProManage</p>
          </div>
          <div className="grid grid-cols-2 md:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-8">
            {teamMembers.map((member, index) => (
              <div key={index} className="text-center group">
                <div className="relative mb-3 sm:mb-4 overflow-hidden rounded-xl sm:rounded-2xl">
                  <ImageWithFallback
                    src={member.image}
                    alt={member.name}
                    className="w-full aspect-square object-cover group-hover:scale-110 transition-transform duration-300"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/50 to-transparent opacity-0 group-hover:opacity-100 transition-opacity"></div>
                </div>
                <h4 className="text-sm sm:text-xl font-bold text-gray-900 mb-1">{member.name}</h4>
                <p className="text-gray-600 text-xs sm:text-sm">{member.role}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* UI/UX Methodology */}
      <section className="px-4 py-10 sm:px-6 md:px-12 lg:px-20 md:py-16 bg-gradient-to-br from-blue-50 to-purple-50">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-10 md:mb-12">
            <h3 className="text-2xl sm:text-3xl md:text-4xl font-bold text-gray-900 mb-3">UI/UX Methodology</h3>
            <p className="text-sm sm:text-lg text-gray-600 max-w-3xl mx-auto">
              Our design follows a User Centered Design approach, ensuring every feature
              is crafted with the end-user in mind.
            </p>
          </div>
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-3 sm:gap-6">
            {[
              { step: '01', title: 'User Research', desc: 'Understanding user needs' },
              { step: '02', title: 'Wireframing', desc: 'Sketching layouts' },
              { step: '03', title: 'Prototyping', desc: 'Creating interactive models' },
              { step: '04', title: 'Usability Testing', desc: 'Gathering feedback' },
              { step: '05', title: 'Improvement', desc: 'Iterative refinement' },
            ].map((item, index) => (
              <div key={index} className="bg-white rounded-xl p-4 sm:p-6 shadow-sm text-center col-span-1 last:col-span-2 sm:last:col-span-1">
                <div className="text-2xl sm:text-3xl font-bold text-red-800 mb-2 sm:mb-3">{item.step}</div>
                <h4 className="font-bold text-gray-900 mb-1 sm:mb-2 text-sm sm:text-base">{item.title}</h4>
                <p className="text-xs sm:text-sm text-gray-600">{item.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Key Initiatives */}
      <section className="px-4 py-10 sm:px-6 md:px-12 lg:px-20 md:py-16 bg-white">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-10 md:mb-12">
            <h3 className="text-2xl sm:text-3xl md:text-4xl font-bold text-gray-900 mb-3">Key Initiatives</h3>
            <p className="text-sm sm:text-lg text-gray-600">Core features that power your project success</p>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
            {initiatives.map((initiative, index) => {
              const Icon = initiative.icon;
              return (
                <div key={index} className="bg-white rounded-xl p-5 sm:p-6 shadow-md hover:shadow-xl transition-shadow border border-gray-100">
                  <div className={`w-12 h-12 sm:w-14 sm:h-14 ${initiative.color} rounded-lg flex items-center justify-center mb-4`}>
                    <Icon className="w-6 h-6 sm:w-7 sm:h-7 text-white" />
                  </div>
                  <h4 className="text-base sm:text-lg font-bold text-gray-900">{initiative.title}</h4>
                </div>
              );
            })}
          </div>
        </div>
      </section>

      {/* Impact and Achievements */}
      <section className="px-4 py-10 sm:px-6 md:px-12 lg:px-20 md:py-16 bg-gray-900 text-white">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-10 md:mb-12">
            <h3 className="text-2xl sm:text-3xl md:text-4xl font-bold mb-3">Impact & Achievements</h3>
            <p className="text-sm sm:text-lg text-gray-300 max-w-3xl mx-auto">
              Our system has transformed the way teams work together
            </p>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 sm:gap-8">
            {[
              { val: '85%', label: 'Improved Project Organization' },
              { val: '92%', label: 'Enhanced Team Collaboration' },
              { val: '78%', label: 'Increased Monitoring Efficiency' },
            ].map(({ val, label }, i) => (
              <div key={i} className="text-center">
                <div className="text-3xl sm:text-4xl font-bold text-red-400 mb-2">{val}</div>
                <p className="text-gray-300 text-sm sm:text-base">{label}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Contact Us */}
      <section className="px-4 py-10 sm:px-6 md:px-12 lg:px-20 md:py-16 bg-white">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-10 md:mb-12">
            <h3 className="text-2xl sm:text-3xl md:text-4xl font-bold text-gray-900 mb-3">Contact Us</h3>
            <p className="text-sm sm:text-lg text-gray-600">We'd love to hear from you</p>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 sm:gap-6 mb-8">
            {[
              { bg: 'from-blue-50 to-blue-100', icon: Mail, iconBg: 'bg-blue-600', title: 'Email', val: 'contact@promanage.com' },
              { bg: 'from-green-50 to-green-100', icon: Phone, iconBg: 'bg-green-600', title: 'Phone', val: '+62 812 3456 7890' },
              { bg: 'from-purple-50 to-purple-100', icon: MapPin, iconBg: 'bg-purple-600', title: 'Location', val: 'Jakarta, Indonesia' },
            ].map(({ bg, icon: Icon, iconBg, title, val }, i) => (
              <div key={i} className={`bg-gradient-to-br ${bg} rounded-xl p-5 sm:p-6 text-center`}>
                <div className={`w-10 h-10 sm:w-12 sm:h-12 ${iconBg} rounded-full flex items-center justify-center mx-auto mb-3 sm:mb-4`}>
                  <Icon className="w-5 h-5 sm:w-6 sm:h-6 text-white" />
                </div>
                <h4 className="font-bold text-gray-900 mb-1 sm:mb-2 text-sm sm:text-base">{title}</h4>
                <p className="text-gray-600 text-xs sm:text-sm">{val}</p>
              </div>
            ))}
          </div>
          <div className="flex justify-center gap-3 sm:gap-4">
            {[Facebook, Twitter, Linkedin, Instagram].map((Icon, i) => (
              <a key={i} href="#" className="w-10 h-10 sm:w-12 sm:h-12 bg-gray-100 hover:bg-red-800 rounded-full flex items-center justify-center transition-colors group">
                <Icon className="w-4 h-4 sm:w-5 sm:h-5 text-gray-600 group-hover:text-white" />
              </a>
            ))}
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="px-4 py-6 sm:px-6 md:px-12 lg:px-20 border-t border-gray-200 bg-gray-50">
        <div className="max-w-7xl mx-auto text-center text-gray-600 text-sm">
          <p>© 2026 ProManage. Platform Manajemen Proyek Mahasiswa.</p>
        </div>
      </footer>
    </div>
  );
}