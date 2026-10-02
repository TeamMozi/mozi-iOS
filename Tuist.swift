import ProjectDescription

/// CI 러너에서만 Swift 패키지를 저장소 안 `.derivedData/SourcePackages` 에 받는다.
/// 캐시 복원 단계가 채워 둔 폴더를 xcodebuild 가 그대로 쓰게 하려는 것이다.
/// 매니페스트 프로세스에는 셸 환경 변수가 전달되지 않으므로 Tuist 의 `TUIST_` 통로를 쓴다.
private let packageResolutionArguments: [String] = {
    let workspacePath = Environment.ciWorkspace.getString(default: "")
    guard workspacePath.isEmpty == false else { return [] }
    var arguments = ["-clonedSourcePackagesDirPath", "\(workspacePath)/.derivedData/SourcePackages"]
    // 복원한 캐시의 패키지 해시가 지금과 같을 때만 CI 가 켠다. 켜지 않으면 원격에 다시 물어 수십 초가 든다.
    if Environment.ciSkipPackageUpdates.getBoolean(default: false) {
        arguments.append("-skipPackageUpdates")
    }
    return arguments
}()

let tuist = Tuist(
    project: .tuist(
        compatibleXcodeVersions: .all,
        generationOptions: .options(
            additionalPackageResolutionArguments: packageResolutionArguments
        )
    )
)
