/// Named routes for all 30 Momo screens.
///
/// One codebase, two presentations: every route renders a mobile layout
/// on narrow screens and a desktop layout (sidebar shell + wider content)
/// on wide screens — the 30 mobile + 30 web screens of the V7 design.
class AppRoutes {
  AppRoutes._();

  /// 01 Splash.
  static const String splash = '/splash';

  /// 02 Onboarding: meet Momo.
  static const String onboardingA = '/onboarding-a';

  /// 03 Onboarding: one index, three inputs.
  static const String onboardingB = '/onboarding-b';

  /// 04 Add Your Details (budget + categories setup).
  static const String addDetails = '/add-details';

  /// 05 Home.
  static const String home = '/home';

  /// 06 Mood Check-in (10 questions).
  static const String checkin = '/checkin';

  /// 07 Check-in Result (formula shown).
  static const String checkinResult = '/checkin-result';

  /// 08 Routines.
  static const String routines = '/routines';

  /// 09 Routine Detail (arguments: routine id [String]).
  static const String routineDetail = '/routine-detail';

  /// 10 Overlay Bubble.
  static const String overlay = '/overlay';

  /// 11 Widget.
  static const String widget = '/widget';

  /// 12 Lock-screen Check-in.
  static const String lockScreen = '/lock-screen';

  /// 13 Happiness Bands.
  static const String bands = '/bands';

  /// 14 Budget Tracker.
  static const String budget = '/budget';

  /// 15 Insights.
  static const String insights = '/insights';

  /// 16 History.
  static const String history = '/history';

  /// 17 Goal Setter.
  static const String goals = '/goals';

  /// 18 Milestone.
  static const String milestone = '/milestone';

  /// 19 Settings.
  static const String settings = '/settings';

  /// 20 Privacy First.
  static const String privacy = '/privacy';

  /// 21 Welcome (guest-first).
  static const String welcome = '/welcome';

  /// 22 Guest Mode.
  static const String guest = '/guest';

  /// 23 Sign In.
  static const String signIn = '/sign-in';

  /// 24 Create Account.
  static const String createAccount = '/create-account';

  /// 25 Verify (magic link + 6-digit code).
  static const String verify = '/verify';

  /// 26 Upgrade Prompt (sharing needs an account).
  static const String upgrade = '/upgrade';

  /// 27 Migrate (guest data moves to the account).
  static const String migrate = '/migrate';

  /// 28 Account.
  static const String account = '/account';

  /// 29 Connected (share link + devices).
  static const String connected = '/connected';

  /// 30 Data Controls (export, sign out, delete).
  static const String dataControls = '/data-controls';

  /// All 30 routes, in screen order.
  static const List<String> all = [
    splash,
    onboardingA,
    onboardingB,
    addDetails,
    home,
    checkin,
    checkinResult,
    routines,
    routineDetail,
    overlay,
    widget,
    lockScreen,
    bands,
    budget,
    insights,
    history,
    goals,
    milestone,
    settings,
    privacy,
    welcome,
    guest,
    signIn,
    createAccount,
    verify,
    upgrade,
    migrate,
    account,
    connected,
    dataControls,
  ];

  /// Display labels for the screen atlas in Settings.
  static const Map<String, String> labels = {
    splash: 'Splash',
    onboardingA: 'Onboarding: A Pet',
    onboardingB: 'Onboarding: Stay on Track',
    addDetails: 'Add Your Details',
    home: 'Home',
    checkin: 'Mood Check-in',
    checkinResult: 'Check-in Result',
    routines: 'Routines',
    routineDetail: 'Routine Detail',
    overlay: 'Overlay Bubble',
    widget: 'Widget',
    lockScreen: 'Lock-screen Check-in',
    bands: 'Happiness Bands',
    budget: 'Budget Tracker',
    insights: 'Insights',
    history: 'History',
    goals: 'Goal Setter',
    milestone: 'Milestone',
    settings: 'Settings',
    privacy: 'Privacy First',
    welcome: 'Welcome',
    guest: 'Guest Mode',
    signIn: 'Sign In',
    createAccount: 'Create Account',
    verify: 'Verify',
    upgrade: 'Upgrade Prompt',
    migrate: 'Migrate',
    account: 'Account',
    connected: 'Connected',
    dataControls: 'Data Controls',
  };
}
