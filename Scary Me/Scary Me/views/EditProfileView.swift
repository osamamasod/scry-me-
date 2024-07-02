import SwiftUI

struct EditProfileView: View {
    @ObservedObject private var viewModel = EditProfileViewModel()
    @State private var isShowingImagePicker = false
    @State private var selectedImage: UIImage? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text("Edit Profile")
                .foregroundColor(.white)
                .font(.custom("BalooPaaji-Regular", size: 30))
                .padding(.top, 60)
            
            ZStack {
                Button(action: {
                    isShowingImagePicker = true
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
                        
                        if let image = selectedImage ?? viewModel.selectedImage {
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
                .actionSheet(isPresented: $isShowingImagePicker) {
                    ActionSheet(title: Text("Select Image Source"), buttons: [
                        .default(Text("Camera")) {
                            viewModel.imageSource = .camera
                            isShowingImagePicker = true
                        },
                        .default(Text("Photo Library")) {
                            viewModel.imageSource = .photoLibrary
                            isShowingImagePicker = true
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
            
            ZStack {
                FloatingTextField(text: $viewModel.aboutText, placeholder: "About")
                    .frame(height: 150)
                    .padding(.horizontal, 17)
                    .background(RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(red: 62/255, green: 28/255, blue: 51/255)))
            }
            .offset(y: -16)
            
            GeometryReader { geometry in
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)], spacing: 20) {
                        ForEach(viewModel.topics, id: \.id) { topic in
                            Button(action: {
                                viewModel.toggleTopicSelection(topic.title)
                            }) {
                                Text(topic.title)
                                    .foregroundColor(viewModel.selectedTopics.contains(topic.title) ? .black : .orange)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(viewModel.selectedTopics.contains(topic.title) ? Color.orange : Color.white.opacity(0.1))
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
            
            Button(action: {
                if viewModel.userName.isEmpty {
                    viewModel.alertMessage = "Please enter a name before saving."
                    viewModel.showAlert = true
                } else {
                    viewModel.saveProfile()
                }
            }) {
                Text("Save")
                    .foregroundColor(.white)
                    .font(.system(size: 15, weight: .semibold))
                    .frame(maxWidth: 300)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(20)
                    .shadow(color: .red, radius: 15, y: 5)
            }
            .padding(.bottom, 14)
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            viewModel.fetchProfile()
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .sheet(isPresented: $isShowingImagePicker) {
         
            ImagePicker(sourceType: viewModel.imageSource, selectedImage: $selectedImage)
                .edgesIgnoringSafeArea(.all) // Adjust as needed
        }
        .onChange(of: viewModel.selectedImage) { newImage in
            selectedImage = newImage
        }
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}
