
import SwiftUI

@main
struct AEROApp: App {
    var body: some Scene {
        WindowGroup {
            AeroHome()
                .preferredColorScheme(.dark)
        }
    }
}

struct AeroHome: View {
    @State private var isActive = false
    @State private var menuOpen = false
    @State private var esp = true
    @State private var box = true
    @State private var skeleton = false
    @State private var radar = false
    @State private var fov: Double = 120

    @AppStorage("aeroX") private var savedX: Double = 0
    @AppStorage("aeroY") private var savedY: Double = 0

    @State private var position = CGPoint.zero
    @State private var initialized = false

    private let purple = Color(
        red: 0.65,
        green: 0.25,
        blue: 1
    )

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(red: 0.035, green: 0.03, blue: 0.055)
                    .ignoresSafeArea()

                Circle()
                    .fill(purple.opacity(0.16))
                    .frame(width: 280)
                    .blur(radius: 100)
                    .offset(x: 100, y: -300)

                VStack(spacing: 24) {
                    header

                    Spacer()

                    VStack(spacing: 14) {
                        Button {
                            isActive = true
                        } label: {
                            Text("START")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [
                                            purple,
                                            purple.opacity(0.7)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 16)
                                )
                        }

                        Button {
                            isActive = false
                            menuOpen = false
                        } label: {
                            Text("STOP")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.09))
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 16)
                                )
                        }
                    }
                    .padding(.horizontal, 28)

                    Text(
                        isActive
                        ? "AERO IS ACTIVE"
                        : "AERO IS STOPPED"
                    )
                    .font(.caption)
                    .foregroundColor(isActive ? .green : .gray)

                    Spacer()

                    Text("AERO PURPLE GLASS • iOS EDITION")
                        .font(.system(size: 10, weight: .medium))
                        .tracking(2)
                        .foregroundColor(.gray)
                        .padding(.bottom, 25)
                }

                if isActive {
                    floatingButton(in: geo.size)
                }

                if menuOpen {
                    menuPanel
                        .transition(
                            .scale.combined(with: .opacity)
                        )
                        .zIndex(10)
                }
            }
            .coordinateSpace(name: "AEROArea")
            .onAppear {
                if !initialized {
                    position = CGPoint(
                        x: savedX == 0
                            ? geo.size.width - 65
                            : savedX,
                        y: savedY == 0
                            ? geo.size.height / 2
                            : savedY
                    )

                    initialized = true
                }
            }
            .animation(
                .spring(response: 0.35),
                value: menuOpen
            )
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("AERO")
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(.white)

                Text("PURPLE GLASS")
                    .font(.caption)
                    .tracking(3)
                    .foregroundColor(purple)
            }

            Spacer()

            Image(systemName: "bolt.fill")
                .font(.system(size: 23))
                .foregroundColor(purple)
        }
        .padding(.horizontal, 28)
        .padding(.top, 35)
    }

    private func floatingButton(in size: CGSize) -> some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [purple, Color.black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Circle()
                    .stroke(
                        Color.white.opacity(0.5),
                        lineWidth: 1
                    )
            }
            .overlay {
                Text("A")
                    .font(.system(size: 27, weight: .black))
                    .foregroundColor(.white)
            }
            .frame(width: 58, height: 58)
            .shadow(color: purple.opacity(0.7), radius: 15)
            .position(position)
            .gesture(
                DragGesture(
                    coordinateSpace: .named("AEROArea")
                )
                .onChanged { value in
                    position = value.location
                }
                .onEnded { value in
                    let x = min(
                        max(value.location.x, 35),
                        size.width - 35
                    )

                    let y = min(
                        max(value.location.y, 60),
                        size.height - 60
                    )

                    position = CGPoint(x: x, y: y)

                    savedX = x
                    savedY = y
                }
            )
            .onTapGesture {
                menuOpen.toggle()
            }
    }

    private var menuPanel: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .onTapGesture {
                    menuOpen = false
                }

            VStack(spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AERO MENU")
                            .font(.title2.bold())
                            .foregroundColor(.white)

                        Text("MODIFICATION PANEL V1.0")
                            .font(.system(size: 9))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Button {
                        menuOpen = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(purple)
                    }
                }

                Divider()
                    .overlay(purple.opacity(0.5))

                settingRow("ESP", value: $esp)
                settingRow("Box", value: $box)
                settingRow("Skeleton", value: $skeleton)
                settingRow("Radar", value: $radar)

                Divider()
                    .overlay(purple.opacity(0.5))

                HStack {
                    Text("FOV")
                        .foregroundColor(.white)

                    Spacer()

                    Text("\(Int(fov))°")
                        .foregroundColor(purple)
                }

                Slider(value: $fov, in: 30...180)
                    .tint(purple)

                Text("AERO PURPLE GLASS")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(2)
                    .foregroundColor(.gray)
            }
            .padding(22)
            .background(.ultraThinMaterial)
            .background(Color.black.opacity(0.7))
            .overlay {
                RoundedRectangle(cornerRadius: 25)
                    .stroke(
                        purple.opacity(0.65),
                        lineWidth: 1
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .shadow(color: purple.opacity(0.3), radius: 25)
            .padding(25)
        }
    }

    private func settingRow(
        _ name: String,
        value: Binding<Bool>
    ) -> some View {
        HStack {
            Text(name)
                .foregroundColor(.white)

            Spacer()

            Toggle(name, isOn: value)
                .labelsHidden()
                .tint(purple)
        }
    }
}
