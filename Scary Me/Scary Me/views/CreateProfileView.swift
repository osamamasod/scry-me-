import SwiftUI

struct CreateProfileView: View {
    @StateObject private var viewModel = CreateProfileViewModel()
    @State private var isShowingImagePicker = false
    @State private var selectedImage: UIImage? = nil

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Why Are You Scary?")
                    .foregroundColor(.white)
                    .font(.custom("BalooPaaji-Regular", size: 30))
                    .padding(.top, 60)

                ZStack {
                    Button(action: {
                        viewModel.showImageSourceSelection()
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 62/255, green: 28/255, blue: 51/255))
                                .frame(width: 150, height: 150)
                                .overlay(
                                    Circle()
                                        .stroke(Color.orange, lineWidth: 4)
                                        .shadow(color: .orange, radius: 10)
                                )

                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .shadow(color: .black, radius: 5, x: 0, y: 2)
                            } else {
                                Image("defaultAvatar")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .shadow(color: .black, radius: 5, x: 0, y: 2)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.clear, lineWidth: 4)
                                            .shadow(color: Color.black.opacity(0.5), radius: 10, x: 0, y: 5)
                                    )
                            }
                        }
                    }
                    .actionSheet(isPresented: $viewModel.showImagePicker) {
                        ActionSheet(title: Text("Select Image Source"), buttons: [
                            .default(Text("Camera")) {
                                isShowingImagePicker = true
                                viewModel.imageSource = .camera
                            },
                            .default(Text("Photo Library")) {
                                isShowingImagePicker = true
                                viewModel.imageSource = .photoLibrary
                            },
                            .cancel()
                        ])
                    }
                }

                FloatingTextField(text: $viewModel.userName, placeholder: "Name")
                    .padding()
                    .background(Color(red: 62/255, green: 28/255, blue: 51/255))
                    .cornerRadius(15)
                    .foregroundColor(.white)
                    .autocapitalization(.none)
                    .keyboardType(.default)
                    .onTapGesture {
                        dismissKeyboard()
                    }

                ZStack {
                    FloatingTextField(text: $viewModel.aboutText, placeholder: "About")
                        .frame(height: 150)
                        .padding(.horizontal, 17)
                        .background(RoundedRectangle(cornerRadius: 15)
                            .fill(Color(red: 62/255, green: 28/255, blue: 51/255)))
                        .onTapGesture {
                            dismissKeyboard()
                        }
                }
                .offset(y: -16)

                Text("Party Topics")
                    .foregroundColor(.white)
                    .font(.custom("BalooPaaji-Regular", size: 30))
                    .offset(y: -20)

                GeometryReader { geometry in
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)], spacing: 20) {
                            ForEach(viewModel.topics.indices, id: \.self) { index in
                                Button(action: {
                                    toggleTopicSelection(viewModel.topics[index].title)
                                }) {
                                    Text(viewModel.topics[index].title)
                                        .foregroundColor(viewModel.selectedTopics.contains(viewModel.topics[index].title) ? .black : .orange)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(viewModel.selectedTopics.contains(viewModel.topics[index].title) ? Color.orange : Color.white.opacity(0.1))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(Color.orange, lineWidth: 1)
                                                )
                                        )
                                }
                            }
                        }
                        .frame(width: geometry.size.width)
                        .padding(.top, 5)
                    }
                    .frame(height: 50)
                }

                Spacer()

                NavigationLink(destination: MainScreen(selectedTab: .profile), isActive: $viewModel.navigateToMainScreen) {
                    Text("Save")
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: 300)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(20)
                        .shadow(color: .red, radius: 15, y: 5)
                        .onTapGesture {
                            if viewModel.userName.isEmpty {
                                viewModel.showAlert = true
                            } else {
                                viewModel.saveProfile()
                            }
                        }
                }
                .alert(isPresented: $viewModel.showAlert) {
                    Alert(
                        title: Text("Empty Name"),
                        message: Text("Please enter a name before saving."),
                        dismissButton: .default(Text("OK"))
                    )
                }

                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .onAppear {
                viewModel.fetchTopics()
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $isShowingImagePicker) {
           
            ImagePicker(sourceType: viewModel.imageSource, selectedImage: $selectedImage)
                .edgesIgnoringSafeArea(.all) // Adjust as needed
        }
    }

    private func toggleTopicSelection(_ topic: String) {
        if viewModel.selectedTopics.contains(topic) {
            viewModel.selectedTopics.remove(topic)
        } else {
            viewModel.selectedTopics.insert(topic)
        }
    }

    private func dismissKeyboard() {
       
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct CreateProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CreateProfileView()
    }
}
