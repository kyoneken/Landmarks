## お気に入りのランドマークをマークする

### ステップ 1
スタートプロジェクトをXcodeで開き、プロジェクトナビゲーターで「Landmark.swift」を選択します。

### ステップ 2
`Landmark`構造体に`isFavorite`プロパティを追加します。

```swift
// Landmark.swift に追加
struct Landmark: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var park: String
    var state: String
    var description: String
    var isFavorite: Bool  // この行を追加
    
    // 他のプロパティは変更なし
}
```

### ステップ 3
プロジェクトナビゲーターで「LandmarkRow.swift」を選択します。

### ステップ 4
お気に入りのランドマークに星を表示するため、スペーサーの後に`if`文を追加します。

```swift
// LandmarkRow.swift の body プロパティ内を変更
var body: some View {
    HStack {
        landmark.image
            .resizable()
            .frame(width: 50, height: 50)
        Text(landmark.name)
        
        Spacer()
        
        // 以下の if 文を追加
        if landmark.isFavorite {
            Image(systemName: "star.fill")
        }
    }
}
```

### ステップ 5
星の画像に色を追加します。

```swift
// LandmarkRow.swift の if 文内を変更
if landmark.isFavorite {
    Image(systemName: "star.fill")
        .foregroundStyle(.yellow)  // この行を追加
}
```

## リストビューをフィルタリングする

### ステップ 1
プロジェクトナビゲーターで「LandmarkList.swift」を選択します。

### ステップ 2
`LandmarkList`構造体に状態変数を追加します。

```swift
// LandmarkList.swift に追加
struct LandmarkList: View {
    @State private var showFavoritesOnly = false  // この行を追加
    
    // 既存のコード
}
```

### ステップ 3
キャンバスが自動的に更新されます。

### ステップ 4
フィルタリング用の計算プロパティを追加します。

```swift
// LandmarkList.swift に追加（@State 変数の後）
var filteredLandmarks: [Landmark] {
    landmarks.filter { landmark in
        (!showFavoritesOnly || landmark.isFavorite)
    }
}
```

### ステップ 5
フィルタリングされたリストを使用するように`List`を更新します。

```swift
// LandmarkList.swift の body プロパティ内を変更（変更前）
var body: some View {
    NavigationSplitView {
        List(landmarks) { landmark in
            NavigationLink {
                LandmarkDetail(landmark: landmark)
            } label: {
                LandmarkRow(landmark: landmark)
            }
        }
        .navigationTitle("Landmarks")
    } detail: {
        Text("Select a Landmark")
    }
}

// 変更後
var body: some View {
    NavigationSplitView {
        List(filteredLandmarks) { landmark in  // landmarks を filteredLandmarks に変更
            NavigationLink {
                LandmarkDetail(landmark: landmark)
            } label: {
                LandmarkRow(landmark: landmark)
            }
        }
        .navigationTitle("Landmarks")
    } detail: {
        Text("Select a Landmark")
    }
}
```

### ステップ 6
`showFavoritesOnly`の初期値を一時的に`true`に変更してテストします。

```swift
// LandmarkList.swift
@State private var showFavoritesOnly = true  // false から true に変更
```

## 状態を切り替えるコントロールを追加する

### ステップ 1
静的と動的ビューを組み合わせるために、`List`内に`ForEach`を追加します。

```swift
// LandmarkList.swift の body プロパティ内を変更（変更前）
var body: some View {
    NavigationSplitView {
        List(filteredLandmarks) { landmark in
            NavigationLink {
                LandmarkDetail(landmark: landmark)
            } label: {
                LandmarkRow(landmark: landmark)
            }
        }
        .navigationTitle("Landmarks")
    } detail: {
        Text("Select a Landmark")
    }
}

// 変更後
var body: some View {
    NavigationSplitView {
        List {
            ForEach(filteredLandmarks) { landmark in
                NavigationLink {
                    LandmarkDetail(landmark: landmark)
                } label: {
                    LandmarkRow(landmark: landmark)
                }
            }
        }
        .navigationTitle("Landmarks")
    } detail: {
        Text("Select a Landmark")
    }
}
```

### ステップ 2
`List`の最初の子要素として`Toggle`を追加します。

```swift
// LandmarkList.swift の List 内、ForEach の前に追加
List {
    Toggle(isOn: $showFavoritesOnly) {
        Text("Favorites only")
    }
    
    ForEach(filteredLandmarks) { landmark in
        // 既存のコード
    }
}
```

### ステップ 3
フィルタリングのアニメーションを追加します。

```swift
// LandmarkList.swift の List の後に追加
List {
    // 既存のコード
}
.animation(.default, value: filteredLandmarks)
.navigationTitle("Landmarks")
```

### ステップ 4
`showFavoritesOnly`のデフォルト値を`false`に戻します。

```swift
// LandmarkList.swift
@State private var showFavoritesOnly = false  // true から false に戻す
```

## 保存にObservationを使用する

### ステップ 1
プロジェクトナビゲーターで「ModelData.swift」を選択します。

### ステップ 2
`Observable`マクロを使用して新しいモデルクラスを作成します。

```swift
// ModelData.swift（変更前）
import Foundation

var landmarks: [Landmark] = load("landmarkData.json")

func load<T: Decodable>(_ filename: String) -> T {
    // 既存のコード
}

// 変更後
import Foundation

@Observable
class ModelData {
    var landmarks: [Landmark] = load("landmarkData.json")
}

func load<T: Decodable>(_ filename: String) -> T {
    // 既存のコード
}
```

### ステップ 3
`landmarks`配列をモデルに移動します（上記のコードで既に実施しています）。

## ビューでモデルオブジェクトを採用する

### ステップ 1
`LandmarkList`に環境プロパティを追加し、プレビューを更新します。

```swift
// LandmarkList.swift（変更前）
struct LandmarkList: View {
    @State private var showFavoritesOnly = false
    
    var filteredLandmarks: [Landmark] {
        landmarks.filter { landmark in
            (!showFavoritesOnly || landmark.isFavorite)
        }
    }
    
    // 残りのコード
}

// 変更後
struct LandmarkList: View {
    @Environment(ModelData.self) var modelData  // この行を追加
    @State private var showFavoritesOnly = false
    
    var filteredLandmarks: [Landmark] {
        // 以下は次のステップで変更
        landmarks.filter { landmark in
            (!showFavoritesOnly || landmark.isFavorite)
        }
    }
    
    // 残りのコード
}

#Preview {
    LandmarkList()
        .environment(ModelData())  // この行を追加
}
```

### ステップ 2
フィルタリングロジックを更新して`modelData.landmarks`を使用します。

```swift
// LandmarkList.swift の filteredLandmarks 内を変更
var filteredLandmarks: [Landmark] {
    modelData.landmarks.filter { landmark in  // landmarks を modelData.landmarks に変更
        (!showFavoritesOnly || landmark.isFavorite)
    }
}
```

### ステップ 3
`LandmarkDetail`にも環境プロパティを追加します。

```swift
// LandmarkDetail.swift に追加
struct LandmarkDetail: View {
    @Environment(ModelData.self) var modelData  // この行を追加
    var landmark: Landmark
    
    // 残りのコード
}
```

### ステップ 4
`LandmarkRow`のプレビューを更新します。

```swift
// LandmarkRow.swift のプレビューを変更
#Preview {
    let landmarks = ModelData().landmarks
    return Group {
        LandmarkRow(landmark: landmarks[0])
        LandmarkRow(landmark: landmarks[1])
    }
}
```

### ステップ 5
`ContentView`のプレビューを更新します。

```swift
// ContentView.swift のプレビューを変更
#Preview {
    ContentView()
        .environment(ModelData())  // この行を追加
}
```

### ステップ 6
アプリインスタンスを更新して、モデルを環境に提供します。

```swift
// LandmarksApp.swift を変更
@main
struct LandmarksApp: App {
    @State private var modelData = ModelData()  // この行を追加
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(modelData)  // この行を追加
        }
    }
}
```

## 各ランドマークのお気に入りボタンを作成する

### ステップ 1
「FavoriteButton.swift」という新しいファイルを作成し、以下のコードを追加します：

```swift
// FavoriteButton.swift の新規作成
import SwiftUI

struct FavoriteButton: View {
    @Binding var isSet: Bool
    
    var body: some View {
        Button {
            isSet.toggle()
        } label: {
            Label("Toggle Favorite", systemImage: isSet ? "star.fill" : "star")
                .labelStyle(.iconOnly)
                .foregroundStyle(isSet ? .yellow : .gray)
        }
    }
}

#Preview {
    FavoriteButton(isSet: .constant(true))
}
```

### ステップ 4
汎用的なヘルパービューとランドマークビューを整理するために、プロジェクトナビゲーターでグループを作成します（これはUIの操作です）。

### ステップ 5
`LandmarkDetail`にランドマークのインデックスを計算するコードを追加します。

```swift
// LandmarkDetail.swift に追加
var landmarkIndex: Int {
    modelData.landmarks.firstIndex(where: { $0.id == landmark.id })!
}
```

### ステップ 6
`LandmarkDetail`のボディにお気に入りボタンを追加します。

```swift
// LandmarkDetail.swift の body 内を変更（変更前）
var body: some View {
    ScrollView {
        MapView(coordinate: landmark.locationCoordinate)
            .frame(height: 300)
        
        CircleImage(image: landmark.image)
            .offset(y: -130)
            .padding(.bottom, -130)
        
        VStack(alignment: .leading) {
            Text(landmark.name)
                .font(.title)
            
            HStack {
                Text(landmark.park)
                Spacer()
                Text(landmark.state)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            
            Divider()
            
            Text("About \(landmark.name)")
                .font(.title2)
            Text(landmark.description)
        }
        .padding()
    }
    .navigationTitle(landmark.name)
    .navigationBarTitleDisplayMode(.inline)
}

// 変更後
var body: some View {
    @Bindable var modelData = modelData  // この行を追加
    
    ScrollView {
        MapView(coordinate: landmark.locationCoordinate)
            .frame(height: 300)
        
        CircleImage(image: landmark.image)
            .offset(y: -130)
            .padding(.bottom, -130)
        
        VStack(alignment: .leading) {
            HStack {  // この行とその内容を変更
                Text(landmark.name)
                    .font(.title)
                FavoriteButton(isSet: $modelData.landmarks[landmarkIndex].isFavorite)
            }
            
            HStack {
                Text(landmark.park)
                Spacer()
                Text(landmark.state)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            
            Divider()
            
            Text("About \(landmark.name)")
                .font(.title2)
            Text(landmark.description)
        }
        .padding()
    }
    .navigationTitle(landmark.name)
    .navigationBarTitleDisplayMode(.inline)
}
```

### ステップ 7
`LandmarkList`に戻り、ライブプレビューでお気に入り機能をテストします。

これで「Handling User Input」チュートリアルの全ステップがコードブロックと差分表示で説明できました。ユーザーがお気に入りのランドマークを追加・削除できるようになり、お気に入りのみを表示するフィルタも実装されました。

---

# 「Handling User Input」章のポイント要約

## 復習するべきキーワード

### **状態管理関連**
- **`@State`** - ビュー内の状態を管理するプロパティラッパー
- **`@Observable`** - データモデルを観測可能にするマクロ（iOS 17+）
- **`@Environment`** - 環境からデータを読み取るプロパティラッパー
- **`@Bindable`** - 観測可能オブジェクトをバインド可能にするラッパー
- **`@Binding`** - 親ビューの状態への参照を作成するプロパティラッパー

### **UI コンポーネント**
- **`Toggle`** - オン/オフを切り替えるUI要素
- **`ForEach`** - 動的なリスト要素の生成
- **バインディング構文（`$`）** - 状態変数への双方向参照

### **データフロー**
- **`environment(_:)`** - 環境にデータを注入するモディファイア
- **条件付きビュー表示（`if`文）** - 状態に応じたUI表示制御

## SwiftUIの機能で解決したこと（UIKitとの違い）

### **1. 宣言的な状態管理**
```swift
// SwiftUI
@State private var showFavoritesOnly = false

// UIKit では
// プロパティ定義 + IBOutlet接続 + 手動での状態同期が必要
```

### **2. 自動的なデータバインディング**
```swift
// SwiftUI - 自動で双方向バインディング
Toggle(isOn: $showFavoritesOnly) {
    Text("Favorites only")
}

// UIKit では
// IBAction メソッド + 手動での状態更新が必要
```

### **3. 環境を通じたデータ共有**
```swift
// SwiftUI - 環境経由で自動的にデータが流れる
@Environment(ModelData.self) var modelData

// UIKit では
// delegate パターンや NotificationCenter、
// または手動でのデータ受け渡しが必要
```

### **4. 条件付きUI表示**
```swift
// SwiftUI - 宣言的に条件表示
if landmark.isFavorite {
    Image(systemName: "star.fill")
        .foregroundStyle(.yellow)
}

// UIKit では
// isHidden プロパティの制御や
// addSubview/removeFromSuperview の手動制御が必要
```

### **5. リアクティブなUIフィルタリング**
```swift
// SwiftUI - 計算プロパティで自動更新
var filteredLandmarks: [Landmark] {
    modelData.landmarks.filter { landmark in
        (!showFavoritesOnly || landmark.isFavorite)
    }
}

// UIKit では
// データソースの手動更新 + reloadData() の呼び出しが必要
```

### **6. 観測パターンの簡素化**
```swift
// SwiftUI - @Observable で自動観測
@Observable
class ModelData {
    var landmarks: [Landmark] = load("landmarkData.json")
}

// UIKit では
// KVO、NotificationCenter、または手動での observer パターン実装が必要
```

## 主な学習成果

1. **状態駆動UI**: UIの表示が状態に完全に依存し、状態が変われば自動的にUIが更新される
2. **データフローの理解**: `@State` → `@Binding` → `@Environment` の階層的なデータ流れ
3. **宣言的プログラミング**: 「どうやって」ではなく「何を表示するか」に集中できる設計
4. **コンポーネントの再利用性**: `FavoriteButton`のような独立したコンポーネントの作成方法

SwiftUIは従来のUIKitの命令的なアプローチと異なり、**宣言的でリアクティブなUI構築**を可能にし、特に状態管理とデータバインディングの複雑さを大幅に軽減していることがこの章の最大のポイントです。