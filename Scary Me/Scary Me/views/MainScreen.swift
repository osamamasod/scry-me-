import SwiftUI
struct MainScreen: View {
    enum Tab {
        case profile
        case chat
        case tinder
    }
    
    @State private var selectedTab: Tab = .profile
    
    init(selectedTab: Tab) {
        self._selectedTab = State(initialValue: selectedTab)
        
        // the tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 19/255, green: 9/255, blue: 18/255, alpha: 1)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View{
        
        TabView(selection: $selectedTab){
            EditProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(Tab.profile)
            
            ChatView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chat")
                }
                .tag(Tab.chat)
            
            TinderView()
                .tabItem {
                    Image(systemName: "flame.fill")
                    Text("Tinder")
                }
                .tag(Tab.tinder)
        }
        .accentColor(.orange)
        .onAppear {
          
            selectedTab = .tinder
        }
    }
}



struct ChatView: View {
    var body: some View {
        ZStack {
            Color(red: 19/255, green: 9/255, blue: 18/255)
                .edgesIgnoringSafeArea(.all)
           
            Text("Chat")
                .foregroundColor(.white)
        }
    }
}




struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen(selectedTab: .tinder)
    }
}
