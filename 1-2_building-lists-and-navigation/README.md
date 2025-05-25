# SwiftUIのリストとナビゲーション構築

このチュートリアルでは、基本的なランドマーク詳細ビューを元に、ユーザーがランドマークの一覧を閲覧し、各ランドマークの詳細を見るための機能を実装していきます。

まず、任意のランドマークの情報を表示できるビューを作成し、スクロール可能なリストを動的に生成します。そのリストからタップすると詳細ビューに移動する仕組みを実装します。さらに、異なるデバイスサイズに対応したUIを調整するためにXcodeのプレビュー機能も使用します。

それでは、以下の手順に従って進めていきましょう。

## セクション1: ランドマークモデルの作成

最初のチュートリアルでは、すべてのカスタムビューに情報をハードコーディングしていました。今回は、ビューに渡すためのデータを格納するモデルを作成します。

### ステップ1
ダウンロードしたプロジェクトファイルのResourcesフォルダから`landmarkData.json`をプロジェクトのナビゲーションペインにドラッグします。表示されるダイアログで「Copy items if needed」（必要に応じてアイテムをコピー）とLandmarksターゲットを選択し、「Finish」をクリックします。

このサンプルデータは、このチュートリアルの残りの部分と、以降のすべてのチュートリアルで使用します。

### ステップ2
「File > New > File」を選択してプロジェクトに新しいSwiftファイルを作成し、`Landmark.swift`という名前を付けます。

### ステップ3
`landmarkData`データファイルの一部のキー名と一致するプロパティを持つ`Landmark`構造体を定義します。

```swift
struct Landmark: Codable {
    var id: Int
    var name: String
    var park: String
    var state: String
    var description: String
}
```

`Codable`準拠を追加することで、構造体とデータファイル間のデータ移動が容易になります。このセクションの後半で、ファイルからデータを読み込むために`Codable`プロトコルの`Decodable`コンポーネントを使用します。

### ステップ4
プロジェクトファイルのResourcesフォルダから、JPGファイルをプロジェクトのアセットカタログにドラッグします。Xcodeは各画像のための新しい画像セットを作成します。

これらの新しい画像は、前のチュートリアルで追加したTurtle Rockの画像に加わります。

### ステップ5
データから画像名を読み取るための`imageName`プロパティと、アセットカタログから画像を読み込む計算プロパティ`image`を追加します。

```swift
private var imageName: String
var image: Image {
    Image(imageName)
}
```

このプロパティをprivateにするのは、`Landmarks`構造体のユーザーが画像自体にのみ関心があるためです。

### ステップ6
JSONデータ構造の格納に対応する、ネストされた`Coordinates`型を使用して`coordinates`プロパティを構造体に追加します。

```swift
private var coordinates: Coordinates
struct Coordinates: Codable {
    var latitude: Double
    var longitude: Double
}
```

次のステップで公開計算プロパティを作成するために使用するだけなので、このプロパティをprivateとしてマークします。

### ステップ7
MapKitフレームワークとの対話に役立つ`locationCoordinate`プロパティを計算します。

```swift
var locationCoordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(
        latitude: coordinates.latitude,
        longitude: coordinates.longitude)
}
```

最後に、ファイルからランドマークで初期化された配列を作成します。

### ステップ8
プロジェクトに新しいSwiftファイルを作成し、`ModelData.swift`という名前を付けます。

### ステップ9
アプリのメインバンドルから指定された名前のJSONデータを取得する`load(_:)`メソッドを作成します。

```swift
func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
```

このloadメソッドは、戻り値の型が`Decodable`プロトコル（`Codable`プロトコルの一部）に準拠していることに依存しています。

### ステップ10
`landmarkData.json`から初期化するランドマークの配列を作成します。

```swift
var landmarks: [Landmark] = load("landmarkData.json")
```

ファイルを整理して、増えていくプロジェクトの管理を容易にしましょう。

### ステップ11
`ContentView`、`CircleImage`、および`MapView`をViewsグループに、`landmarkData`をResourcesグループに、`Landmark`と`ModelData`をModelグループに分けます。

**ヒント**: 既存のアイテムのグループを作成するには、グループに追加するアイテムを選択し、Xcodeメニューで「File > New > Group from Selection」を選択します。

## セクション2: 行ビューの作成

このチュートリアルで最初に構築するビューは、各ランドマークの詳細を表示するための行です。この行ビューは、表示するランドマークの情報をプロパティに格納するため、1つのビューで任意のランドマークを表示できます。後で、複数の行を組み合わせてランドマークのリストを作成します。

### ステップ1
Viewsグループに`LandmarkRow.swift`という名前の新しいSwiftUIビューを作成します。

### ステップ2
`LandmarkRow`に格納プロパティとして`landmark`を追加します。

```swift
struct LandmarkRow: View {
    var landmark: Landmark

    var body: some View {
        Text("Hello, World!")
    }
}
```

`landmark`プロパティを追加すると、キャンバスのプレビューが機能しなくなります。これは、`LandmarkRow`型が初期化時にランドマークインスタンスを必要とするためです。

プレビューを修正するには、プレビューのビューインスタンス化を変更する必要があります。

### ステップ3
プレビューマクロ内で、`LandmarkRow`イニシャライザに`landmark`パラメータを追加し、`landmarks`配列の最初の要素を指定します。

```swift
#Preview {
    LandmarkRow(landmark: landmarks[0])
}
```

プレビューには「Hello, World!」というテキストが表示されます。

これで修正できたので、行のレイアウトを構築できます。

### ステップ4
既存のテキストビューを`HStack`に埋め込みます。

```swift
var body: some View {
    HStack {
        Text("Hello, World!")
    }
}
```

### ステップ5
テキストビューを修正して、`landmark`プロパティの`name`を使用するようにします。

```swift
Text(landmark.name)
```

### ステップ6
テキストビューの前に画像を追加し、その後にスペーサーを追加して行を完成させます。

```swift
HStack {
    landmark.image
        .resizable()
        .frame(width: 50, height: 50)
    Text(landmark.name)
    
    Spacer()
}
```

## セクション3: 行プレビューのカスタマイズ

Xcodeは、ビューのソースファイルでプレビューマクロで宣言したプレビューを自動的に認識します。

キャンバスは一度に1つのプレビューしか表示しませんが、複数のプレビューを定義してキャンバスで選択することができます。または、ビューをグループ化して、1つのビューの複数のバージョンの単一プレビューを作成することもできます。

### ステップ1
`landmarks`配列の2番目の要素を使用する2つ目のプレビューマクロを追加します。

```swift
#Preview {
    LandmarkRow(landmark: landmarks[1])
}
```

プレビューを追加すると、異なるデータでビューがどのように振る舞うかを確認できます。

### ステップ2
キャンバスのコントロールを使用して、2番目のプレビューを選択します。

デフォルトでは、キャンバスはプレビューが表示される行番号を使用してラベル付けします。

プレビューマクロはオプションの`name`パラメータを取り、これを使用してプレビューにラベルを付けることができます。

### ステップ3
各プレビューに区別しやすいように名前を付けます。

```swift
#Preview("Turtle Rock") {
    LandmarkRow(landmark: landmarks[0])
}

#Preview("Salmon") {
    LandmarkRow(landmark: landmarks[1])
}
```

### ステップ4
新しいラベルで2つのプレビュー間を移動してみましょう。もう一度選択したプレビューを変更してみてください。

ビューの異なるバージョンを並べて表示したい場合は、それらを1つのコレクションビューにグループ化することもできます。

### ステップ5
2番目のプレビューを削除し、代わりに行の2つのバージョンを`Group`でラップします。

```swift
#Preview {
    Group {
        LandmarkRow(landmark: landmarks[0])
        LandmarkRow(landmark: landmarks[1])
    }
}
```

`Group`はビューコンテンツをグループ化するためのコンテナです。Xcodeはグループの子ビューを積み重ねて1つのプレビューとしてキャンバスにレンダリングします。

プレビューで記述したコードは、Xcodeがキャンバスに表示する内容のみを変更します。

## セクション4: ランドマークのリストの作成

SwiftUIの`List`型を使用すると、プラットフォーム固有のビューのリストを表示できます。リストの要素は、これまで作成したスタックの子ビューのように静的であったり、動的に生成されたりすることができます。静的ビューと動的に生成されたビューを混在させることもできます。

### ステップ1
Viewsグループに`LandmarkList.swift`という名前の新しいSwiftUIビューを作成します。

### ステップ2
デフォルトの`Text`ビューを`List`に置き換え、リストの子として最初の2つのランドマークを持つ`LandmarkRow`インスタンスを提供します。

```swift
struct LandmarkList: View {
    var body: some View {
        List {
            LandmarkRow(landmark: landmarks[0])
            LandmarkRow(landmark: landmarks[1])
        }
    }
}

#Preview {
    LandmarkList()
}
```

プレビューには、iOSに適したリストスタイルでレンダリングされた2つのランドマークが表示されています。

## セクション5: リストを動的にする

リストの要素を個別に指定する代わりに、コレクションから直接行を生成することができます。

コレクションと、コレクション内の各要素のビューを提供するクロージャを渡すことで、コレクションの要素を表示するリストを作成できます。リストは、提供されたクロージャを使用して、コレクション内の各要素を子ビューに変換します。

### ステップ1
2つの静的なランドマーク行を削除し、代わりにモデルデータの`landmarks`配列を`List`イニシャライザに渡します。

```swift
List(landmarks, id: \.id) { landmark in
    LandmarkRow(landmark: landmark)
}
```

リストは識別可能なデータで動作します。データを識別可能にするには2つの方法があります：各要素を一意に識別するプロパティへのキーパスをデータと一緒に渡すか、データ型を`Identifiable`プロトコルに準拠させるかです。

### ステップ2
クロージャから`LandmarkRow`を返すことで、動的に生成されるリストを完成させます。

```swift
List(landmarks, id: \.id) { landmark in
    LandmarkRow(landmark: landmark)
}
```

これにより、`landmarks`配列の各要素に対して1つの`LandmarkRow`が作成されます。

次に、`Landmark`型に`Identifiable`準拠を追加することでリストコードを簡略化します。

### ステップ3
`Landmark.swift`に切り替えて、`Identifiable`プロトコルへの準拠を宣言します。

```swift
struct Landmark: Codable, Identifiable {
    var id: Int
    var name: String
    var park: String
    var state: String
    var description: String
    // 他のプロパティ...
}
```

`Landmark`データには既に`Identifiable`プロトコルが要求する`id`プロパティがあります。データの読み取り時にデコードするためのプロパティを追加するだけです。

### ステップ4
`LandmarkList.swift`に戻り、`id`パラメータを削除します。

```swift
List(landmarks) { landmark in
    LandmarkRow(landmark: landmark)
}
```

これからは、`Landmark`要素のコレクションを直接使用できます。

## セクション6: リストと詳細間のナビゲーションの設定

リストは正しくレンダリングされますが、まだ個々のランドマークをタップしてそのランドマークの詳細ページを表示することはできません。

リストにナビゲーション機能を追加するには、リストを`NavigationSplitView`に埋め込み、各行を`NavigationLink`でネストして、送信先ビューへの遷移を設定します。

まず、前のチュートリアルで作成したコンテンツを使用して詳細ビューを準備し、メインコンテンツビューを更新してリストビューを表示するようにします。

### ステップ1
`LandmarkDetail.swift`という名前の新しいSwiftUIビューを作成します。

### ステップ2
`ContentView`の`body`プロパティの内容を`LandmarkDetail`にコピーします。

### ステップ3
`ContentView`を変更して、代わりに`LandmarkList`を表示するようにします。

```swift
struct ContentView: View {
    var body: some View {
        LandmarkList()
    }
}
```

次の数ステップで、リストビューと詳細ビュー間のナビゲーションを追加します。

### ステップ4
動的に生成されたランドマークのリストを`NavigationSplitView`に埋め込みます。

```swift
NavigationSplitView {
    List(landmarks) { landmark in
        LandmarkRow(landmark: landmark)
    }
} detail: {
    Text("Select a Landmark")
}
```

ナビゲーションスプリットビューは、誰かが選択した後に表示されるビューのプレースホルダーとして2番目の入力を取ります。iPhoneでは、スプリットビューはプレースホルダーを必要としませんが、iPadでは誰かが選択する前に詳細ペインが存在する場合があります。

### ステップ5
リストを表示するときにナビゲーションバーのタイトルを設定するために、`navigationTitle(_:)`修飾子を追加します。

```swift
NavigationSplitView {
    List(landmarks) { landmark in
        LandmarkRow(landmark: landmark)
    }
    .navigationTitle("Landmarks")
} detail: {
    Text("Select a Landmark")
}
```

### ステップ6
リストのクロージャ内で、返される行を`NavigationLink`でラップし、送信先として`LandmarkDetail`ビューを指定します。

```swift
NavigationSplitView {
    List(landmarks) { landmark in
        NavigationLink {
            LandmarkDetail()
        } label: {
            LandmarkRow(landmark: landmark)
        }
    }
    .navigationTitle("Landmarks")
} detail: {
    Text("Select a Landmark")
}
```

### ステップ7
プレビューで直接ナビゲーションを試すことができます。ランドマークをタップして詳細ページにアクセスしてみましょう。

## セクション7: 子ビューにデータを渡す

`LandmarkDetail`ビューはまだハードコードされた詳細を使用してランドマークを表示しています。`LandmarkRow`と同様に、`LandmarkDetail`型とそれを構成するビューは、データのソースとして`landmark`プロパティを使用する必要があります。

子ビューから始めて、`CircleImage`、`MapView`、そして`LandmarkDetail`を変換して、ハードコーディングするのではなく、渡されたデータを表示するようにします。

### ステップ1
`CircleImage`ファイルで、`CircleImage`構造体に格納された`image`プロパティを追加します。

```swift
struct CircleImage: View {
    var image: Image

    var body: some View {
        image
            .clipShape(Circle())
            .overlay {
                Circle().stroke(.white, lineWidth: 4)
            }
            .shadow(radius: 7)
    }
}
```

これはSwiftUIを使用してビューを構築する際の一般的なパターンです。カスタムビューは特定のビューの一連の修飾子をラップしてカプセル化することがよくあります。

### ステップ2
プレビューを更新して、Turtle Rockの画像を渡します。

```swift
#Preview {
    CircleImage(image: Image("turtlerock"))
}
```

プレビューロジックを修正しましたが、ビルドが失敗するためプレビューは更新されません。円形の画像をインスタンス化する詳細ビューも入力パラメータが必要です。

### ステップ3
`MapView`ファイルで、`MapView`構造体に`coordinate`プロパティを追加し、固定座標を渡すようにプレビューを更新します。

```swift
struct MapView: View {
    var coordinate: CLLocationCoordinate2D

    // その他の既存のコード...
}

#Preview {
    MapView(coordinate: CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868))
}
```

この変更もビルドに影響します。新しいパラメータが必要なマップビューがある詳細ビューを間もなく修正します。

### ステップ4
座標入力が変更されたときにビューを更新できるように、regionの計算にcoordinateパラメータを渡します。

```swift
var body: some View {
    Map(initialPosition: .region(region))
}

private var region: MKCoordinateRegion {
    MKCoordinateRegion(
        center: coordinate,
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
}
```

SwiftUIは、このビューへの`coordinate`入力が変更されたことに気づくと、ビューを再評価して更新します。これにより、新しい入力値を使用して`region`が再計算されます。

### ステップ5
値が変更されたときに更新されるように、位置入力を受け取るマップのイニシャライザに変更します。

```swift
Map(position: .constant(.region(region)))
```

このイニシャライザは位置へのバインディング（双方向接続）を期待しています。マップとの対話による位置の変更を検出する必要がないため、ここでは`.constant()`バインディングを使用します。

### ステップ6
`LandmarkDetail`に`Landmark`プロパティを追加します。

```swift
struct LandmarkDetail: View {
    var landmark: Landmark

    var body: some View {
        // 既存のコード...
    }
}
```

### ステップ7
`LandmarkList`で、現在のランドマークを送信先の`LandmarkDetail`に渡します。

```swift
NavigationLink {
    LandmarkDetail(landmark: landmark)
} label: {
    LandmarkRow(landmark: landmark)
}
```

### ステップ8
`LandmarkDetail`ファイルで、必要なデータをカスタム型に渡します。

```swift
struct LandmarkDetail: View {
    var landmark: Landmark

    var body: some View {
        ScrollView {
            MapView(coordinate: landmark.locationCoordinate)
                .ignoresSafeArea(edges: .top)
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
}
```

すべての接続が確立されると、プレビューが再び機能し始めます。

### ステップ9
コンテナを`VStack`から`ScrollView`に変更して、ユーザーが説明コンテンツをスクロールできるようにし、不要となった`Spacer`を削除します。

### ステップ10
最後に、詳細ビューを表示するときにナビゲーションバーにタイトルを付けるために`navigationTitle(_:)`修飾子を呼び出し、タイトルをインラインで表示するために`navigationBarTitleDisplayMode(_:)`修飾子を呼び出します。

```swift
.navigationTitle(landmark.name)
.navigationBarTitleDisplayMode(.inline)
```

ナビゲーションの変更は、ビューがナビゲーションスタックの一部である場合にのみ効果があります。

### ステップ11
`LandmarkList`プレビューに戻り、リストからナビゲートするときに正しいランドマークが表示されることを確認します。

## セクション8: プレビューを動的に生成する

次に、異なるデバイス構成のリストビューのプレビューをレンダリングします。

デフォルトでは、プレビューはアクティブなスキームのデバイスサイズでレンダリングされます。ターゲットを変更するか、キャンバスでデバイスをオーバーライドすることで、異なるデバイス用にレンダリングできます。デバイスの向きなど、他のプレビューバリエーションも探索できます。

### ステップ1
デバイスセレクタを変更してプレビューをiPadに表示します。

縦向きでは、`NavigationSplitView`はデフォルトで詳細ペインを表示し、サイドバーを表示するためのツールバーにボタンを提供します。

### ステップ2
ツールバーボタンをタップしてサイドバーを表示し、いずれかのランドマークにナビゲートしてみてください。

詳細ビューはサイドバーの下で選択したランドマークに変わります。サイドバーは、詳細ビューのどこかをタップするまで表示されたままになります。

### ステップ3
キャンバスでDevice Settingsを選択し、Landscape Left方向を有効にします。

横向きでは、`NavigationSplitView`はサイドバーと詳細ペインを並べて表示します。

### ステップ4
Device Settingsで異なるデバイスと設定を試して、ビューがさまざまな条件でどのように見えるかを確認してください。

以上で「Building Lists and Navigation」チュートリアルは完了です。次のチュートリアル「Handling User Input」では、ユーザーがお気に入りの場所にフラグを立て、リストをフィルタリングしてお気に入りのみを表示する機能を追加します。
