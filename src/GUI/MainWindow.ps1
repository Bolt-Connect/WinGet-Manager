#Requires -Version 5.1

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

$ScriptRoot = Split-Path $PSScriptRoot -Parent | Split-Path -Parent
Import-Module "$ScriptRoot\src\Core\Logging.psm1"      -Force
Import-Module "$ScriptRoot\src\Core\Config.psm1"       -Force
Import-Module "$ScriptRoot\src\Core\WinGet-Core.psm1"  -Force

$cfg = Get-AppConfig
Initialize-Logging -LogDirectory (Join-Path $ScriptRoot $cfg.LogDirectory) `
                   -MinLevel $cfg.LogLevel `
                   -RetentionDays $cfg.LogRetentionDays `
                   -MaxSizeMB $cfg.MaxLogFileSizeMB

try {
    Initialize-WinGetCore -WinGetPath $cfg.WinGetPath
} catch {
    [System.Windows.MessageBox]::Show($_.Exception.Message, "WinGet niet gevonden", "OK", "Error") | Out-Null
    exit 1
}

# ---------------------------------------------------------------------------
# Observable log collection (gedeeld met Logging module)
# ---------------------------------------------------------------------------

$LogCollection = [System.Collections.ObjectModel.ObservableCollection[object]]::new()
Set-LogObservable $LogCollection

# ---------------------------------------------------------------------------
# XAML definitie
# ---------------------------------------------------------------------------

[xml]$Xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="WinGet Manager" Height="750" Width="1200"
        MinHeight="600" MinWidth="900"
        WindowStartupLocation="CenterScreen"
        Background="#1E1E2E">
    <Window.Resources>
        <!-- Kleuren -->
        <SolidColorBrush x:Key="BgPrimary"    Color="#1E1E2E"/>
        <SolidColorBrush x:Key="BgSecondary"  Color="#2A2A3E"/>
        <SolidColorBrush x:Key="BgCard"       Color="#313149"/>
        <SolidColorBrush x:Key="AccentBlue"   Color="#89B4FA"/>
        <SolidColorBrush x:Key="AccentGreen"  Color="#A6E3A1"/>
        <SolidColorBrush x:Key="AccentRed"    Color="#F38BA8"/>
        <SolidColorBrush x:Key="AccentYellow" Color="#F9E2AF"/>
        <SolidColorBrush x:Key="TextPrimary"  Color="#CDD6F4"/>
        <SolidColorBrush x:Key="TextMuted"    Color="#6C7086"/>
        <SolidColorBrush x:Key="BorderColor"  Color="#45475A"/>

        <!-- Button basis stijl -->
        <Style x:Key="BtnBase" TargetType="Button">
            <Setter Property="Foreground" Value="#CDD6F4"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Padding" Value="16,8"/>
            <Setter Property="FontSize" Value="13"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" CornerRadius="6"
                                Background="{TemplateBinding Background}"
                                Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border" Property="Opacity" Value="0.85"/>
                            </Trigger>
                            <Trigger Property="IsPressed" Value="True">
                                <Setter TargetName="border" Property="Opacity" Value="0.7"/>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter TargetName="border" Property="Opacity" Value="0.4"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="BtnBlue"   BasedOn="{StaticResource BtnBase}" TargetType="Button">
            <Setter Property="Background" Value="#89B4FA"/>
            <Setter Property="Foreground" Value="#1E1E2E"/>
        </Style>
        <Style x:Key="BtnGreen"  BasedOn="{StaticResource BtnBase}" TargetType="Button">
            <Setter Property="Background" Value="#A6E3A1"/>
            <Setter Property="Foreground" Value="#1E1E2E"/>
        </Style>
        <Style x:Key="BtnRed"    BasedOn="{StaticResource BtnBase}" TargetType="Button">
            <Setter Property="Background" Value="#F38BA8"/>
            <Setter Property="Foreground" Value="#1E1E2E"/>
        </Style>
        <Style x:Key="BtnYellow" BasedOn="{StaticResource BtnBase}" TargetType="Button">
            <Setter Property="Background" Value="#F9E2AF"/>
            <Setter Property="Foreground" Value="#1E1E2E"/>
        </Style>
        <Style x:Key="BtnGhost"  BasedOn="{StaticResource BtnBase}" TargetType="Button">
            <Setter Property="Background" Value="#313149"/>
            <Setter Property="Foreground" Value="#CDD6F4"/>
        </Style>

        <!-- TextBox -->
        <Style TargetType="TextBox">
            <Setter Property="Background"    Value="#313149"/>
            <Setter Property="Foreground"    Value="#CDD6F4"/>
            <Setter Property="CaretBrush"    Value="#89B4FA"/>
            <Setter Property="BorderBrush"   Value="#45475A"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding"       Value="10,6"/>
            <Setter Property="FontSize"      Value="13"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TextBox">
                        <Border Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="{TemplateBinding BorderThickness}"
                                CornerRadius="6">
                            <ScrollViewer x:Name="PART_ContentHost" Margin="{TemplateBinding Padding}"/>
                        </Border>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- DataGrid -->
        <Style TargetType="DataGrid">
            <Setter Property="Background"           Value="#2A2A3E"/>
            <Setter Property="Foreground"           Value="#CDD6F4"/>
            <Setter Property="BorderBrush"          Value="#45475A"/>
            <Setter Property="BorderThickness"      Value="1"/>
            <Setter Property="RowBackground"        Value="#2A2A3E"/>
            <Setter Property="AlternatingRowBackground" Value="#313149"/>
            <Setter Property="HorizontalGridLinesBrush" Value="#45475A"/>
            <Setter Property="VerticalGridLinesBrush"   Value="#45475A"/>
            <Setter Property="SelectionMode"        Value="Extended"/>
            <Setter Property="CanUserResizeRows"    Value="False"/>
            <Setter Property="AutoGenerateColumns"  Value="False"/>
        </Style>
        <Style TargetType="DataGridColumnHeader">
            <Setter Property="Background"    Value="#313149"/>
            <Setter Property="Foreground"    Value="#89B4FA"/>
            <Setter Property="FontWeight"    Value="SemiBold"/>
            <Setter Property="Padding"       Value="10,8"/>
            <Setter Property="BorderBrush"   Value="#45475A"/>
        </Style>
        <Style TargetType="DataGridRow">
            <Setter Property="Foreground" Value="#CDD6F4"/>
            <Style.Triggers>
                <Trigger Property="IsSelected" Value="True">
                    <Setter Property="Background" Value="#45475A"/>
                </Trigger>
            </Style.Triggers>
        </Style>

        <!-- Tab -->
        <Style TargetType="TabControl">
            <Setter Property="Background"   Value="#1E1E2E"/>
            <Setter Property="BorderBrush"  Value="#45475A"/>
            <Setter Property="BorderThickness" Value="1"/>
        </Style>
        <Style TargetType="TabItem">
            <Setter Property="Background"   Value="#2A2A3E"/>
            <Setter Property="Foreground"   Value="#6C7086"/>
            <Setter Property="FontSize"     Value="13"/>
            <Setter Property="Padding"      Value="16,8"/>
            <Setter Property="BorderBrush"  Value="#45475A"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TabItem">
                        <Border x:Name="border" Background="{TemplateBinding Background}"
                                BorderBrush="{TemplateBinding BorderBrush}"
                                BorderThickness="0,0,0,2" Padding="{TemplateBinding Padding}">
                            <ContentPresenter x:Name="content"
                                ContentSource="Header"
                                HorizontalAlignment="Center"
                                VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="border"   Property="Background"    Value="#313149"/>
                                <Setter TargetName="border"   Property="BorderBrush"   Value="#89B4FA"/>
                                <Setter TargetName="content"  Property="TextElement.Foreground" Value="#89B4FA"/>
                            </Trigger>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="border"   Property="Background"    Value="#313149"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <!-- Label -->
        <Style TargetType="Label">
            <Setter Property="Foreground" Value="#CDD6F4"/>
            <Setter Property="FontSize"   Value="13"/>
        </Style>

        <!-- ComboBox -->
        <Style TargetType="ComboBox">
            <Setter Property="Background"   Value="#313149"/>
            <Setter Property="Foreground"   Value="#CDD6F4"/>
            <Setter Property="BorderBrush"  Value="#45475A"/>
            <Setter Property="Padding"      Value="8,4"/>
            <Setter Property="FontSize"     Value="13"/>
        </Style>

        <!-- CheckBox -->
        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="#CDD6F4"/>
            <Setter Property="FontSize"   Value="13"/>
        </Style>

        <!-- ProgressBar -->
        <Style TargetType="ProgressBar">
            <Setter Property="Background"  Value="#313149"/>
            <Setter Property="Foreground"  Value="#89B4FA"/>
            <Setter Property="BorderBrush" Value="#45475A"/>
            <Setter Property="Height"      Value="6"/>
        </Style>

        <!-- ScrollBar -->
        <Style TargetType="ScrollBar">
            <Setter Property="Background" Value="#2A2A3E"/>
        </Style>
    </Window.Resources>

    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="56"/>   <!-- Header balk -->
            <RowDefinition Height="*"/>    <!-- Inhoud -->
            <RowDefinition Height="32"/>   <!-- Statusbalk -->
        </Grid.RowDefinitions>

        <!-- ── Header ──────────────────────────────────────────────────── -->
        <Border Grid.Row="0" Background="#313149" BorderBrush="#45475A" BorderThickness="0,0,0,1">
            <Grid Margin="20,0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                    <TextBlock Text="⊞" FontSize="22" Foreground="#89B4FA" VerticalAlignment="Center" Margin="0,0,10,0"/>
                    <TextBlock Text="WinGet Manager" FontSize="18" FontWeight="Bold"
                               Foreground="#CDD6F4" VerticalAlignment="Center"/>
                    <Border Background="#89B4FA" CornerRadius="4" Margin="12,0,0,0" Padding="6,2"
                            VerticalAlignment="Center">
                        <TextBlock x:Name="TxtAppVersion" Text="v1.0.0" FontSize="11"
                                   Foreground="#1E1E2E" FontWeight="SemiBold"/>
                    </Border>
                    <Border x:Name="AdminBadge" Background="#F38BA8" CornerRadius="4"
                            Margin="8,0,0,0" Padding="6,2" VerticalAlignment="Center" Visibility="Collapsed">
                        <TextBlock Text="ADMIN" FontSize="11" Foreground="#1E1E2E" FontWeight="Bold"/>
                    </Border>
                </StackPanel>

                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                    <Button x:Name="BtnCheckUpdates" Content="🔄 Controleer updates"
                            Style="{StaticResource BtnGhost}"/>
                    <Button x:Name="BtnSelfUpdate"   Content="⬆ App updaten"
                            Style="{StaticResource BtnYellow}"/>
                </StackPanel>
            </Grid>
        </Border>

        <!-- ── Tabbladen ─────────────────────────────────────────────── -->
        <TabControl x:Name="MainTabs" Grid.Row="1" Margin="0">

            <!-- ─ Tab 1: Zoeken & Installeren ─ -->
            <TabItem Header="🔍  Zoeken">
                <Grid Margin="20">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <!-- Zoekbalk -->
                    <Grid Grid.Row="0" Margin="0,0,0,16">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="140"/>
                            <ColumnDefinition Width="120"/>
                            <ColumnDefinition Width="100"/>
                        </Grid.ColumnDefinitions>
                        <TextBox x:Name="TxtSearch" Grid.Column="0" Margin="0,0,8,0"
                                 Text="" Tag="Zoek packages..." FontSize="14"/>
                        <ComboBox x:Name="CmbSearchSource" Grid.Column="1" Margin="0,0,8,0">
                            <ComboBoxItem Content="Alle bronnen" IsSelected="True"/>
                            <ComboBoxItem Content="winget"/>
                            <ComboBoxItem Content="msstore"/>
                        </ComboBox>
                        <Button x:Name="BtnSearch" Grid.Column="2" Content="🔍 Zoeken"
                                Style="{StaticResource BtnBlue}" Margin="0,0,8,0"/>
                        <Button x:Name="BtnClearSearch" Grid.Column="3" Content="✕ Wissen"
                                Style="{StaticResource BtnGhost}"/>
                    </Grid>

                    <!-- Resultatenlijst -->
                    <DataGrid x:Name="GridSearch" Grid.Row="1" IsReadOnly="True"
                              SelectionMode="Single" CanUserSortColumns="True">
                        <DataGrid.Columns>
                            <DataGridTextColumn Header="Naam"    Binding="{Binding Name}"    Width="250"/>
                            <DataGridTextColumn Header="ID"      Binding="{Binding Id}"      Width="250"/>
                            <DataGridTextColumn Header="Versie"  Binding="{Binding Version}" Width="100"/>
                            <DataGridTextColumn Header="Bron"    Binding="{Binding Source}"  Width="100"/>
                        </DataGrid.Columns>
                    </DataGrid>

                    <!-- Actieknoppen -->
                    <StackPanel Grid.Row="2" Orientation="Horizontal" Margin="0,12,0,0" HorizontalAlignment="Right">
                        <Button x:Name="BtnInstallSelected" Content="⬇ Installeren"
                                Style="{StaticResource BtnGreen}" Margin="0,0,8,0" IsEnabled="False"/>
                        <Button x:Name="BtnShowDetails" Content="ℹ Details"
                                Style="{StaticResource BtnGhost}" IsEnabled="False"/>
                    </StackPanel>
                </Grid>
            </TabItem>

            <!-- ─ Tab 2: Geïnstalleerd ─ -->
            <TabItem Header="📦  Geïnstalleerd">
                <Grid Margin="20">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <Grid Grid.Row="0" Margin="0,0,0,16">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="130"/>
                        </Grid.ColumnDefinitions>
                        <TextBox x:Name="TxtFilterInstalled" Margin="0,0,8,0" Tag="Filter op naam of ID..."/>
                        <Button x:Name="BtnRefreshInstalled" Grid.Column="1"
                                Content="↺ Vernieuwen" Style="{StaticResource BtnBlue}"/>
                    </Grid>

                    <DataGrid x:Name="GridInstalled" Grid.Row="1" IsReadOnly="True" CanUserSortColumns="True">
                        <DataGrid.Columns>
                            <DataGridTextColumn Header="Naam"        Binding="{Binding Name}"             Width="220"/>
                            <DataGridTextColumn Header="ID"          Binding="{Binding Id}"               Width="230"/>
                            <DataGridTextColumn Header="Versie"      Binding="{Binding Version}"          Width="110"/>
                            <DataGridTextColumn Header="Beschikbaar" Binding="{Binding AvailableVersion}" Width="110"/>
                            <DataGridTextColumn Header="Bron"        Binding="{Binding Source}"           Width="100"/>
                        </DataGrid.Columns>
                        <DataGrid.RowStyle>
                            <Style TargetType="DataGridRow">
                                <Style.Triggers>
                                    <DataTrigger Binding="{Binding HasUpdate}" Value="True">
                                        <Setter Property="Foreground" Value="#A6E3A1"/>
                                    </DataTrigger>
                                </Style.Triggers>
                            </Style>
                        </DataGrid.RowStyle>
                    </DataGrid>

                    <StackPanel Grid.Row="2" Orientation="Horizontal" Margin="0,12,0,0" HorizontalAlignment="Right">
                        <TextBlock x:Name="TxtInstalledCount" Foreground="#6C7086" FontSize="12"
                                   VerticalAlignment="Center" Margin="0,0,16,0"/>
                        <Button x:Name="BtnUninstallSelected" Content="🗑 Verwijderen"
                                Style="{StaticResource BtnRed}" Margin="0,0,8,0" IsEnabled="False"/>
                        <Button x:Name="BtnUpdateSelectedInstalled" Content="⬆ Update geselecteerde"
                                Style="{StaticResource BtnGreen}" IsEnabled="False"/>
                    </StackPanel>
                </Grid>
            </TabItem>

            <!-- ─ Tab 3: Updates ─ -->
            <TabItem Header="⬆  Updates">
                <Grid Margin="20">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <!-- Badge samenvatting -->
                    <Border Grid.Row="0" Background="#313149" CornerRadius="8" Padding="16,10" Margin="0,0,0,16">
                        <StackPanel Orientation="Horizontal">
                            <StackPanel>
                                <TextBlock Text="Beschikbare updates" Foreground="#6C7086" FontSize="11"/>
                                <TextBlock x:Name="TxtUpdateCount" Text="–" Foreground="#89B4FA"
                                           FontSize="24" FontWeight="Bold"/>
                            </StackPanel>
                            <StackPanel>
                                <TextBlock Text="WinGet versie" Foreground="#6C7086" FontSize="11"/>
                                <TextBlock x:Name="TxtWinGetVersion" Text="–" Foreground="#A6E3A1"
                                           FontSize="24" FontWeight="Bold"/>
                            </StackPanel>
                        </StackPanel>
                    </Border>

                    <DataGrid x:Name="GridUpdates" Grid.Row="1" IsReadOnly="True" CanUserSortColumns="True">
                        <DataGrid.Columns>
                            <DataGridCheckBoxColumn Header="" Binding="{Binding Selected, UpdateSourceTrigger=PropertyChanged}"
                                                    Width="36"/>
                            <DataGridTextColumn Header="Naam"              Binding="{Binding Name}"             Width="230"/>
                            <DataGridTextColumn Header="ID"                Binding="{Binding Id}"               Width="220"/>
                            <DataGridTextColumn Header="Huidig"            Binding="{Binding Version}"          Width="110"/>
                            <DataGridTextColumn Header="Beschikbaar"       Binding="{Binding AvailableVersion}" Width="110"/>
                            <DataGridTextColumn Header="Bron"              Binding="{Binding Source}"           Width="100"/>
                        </DataGrid.Columns>
                    </DataGrid>

                    <!-- Voortgangsbalk -->
                    <ProgressBar x:Name="UpdateProgress" Grid.Row="2" Margin="0,12,0,0"
                                 Visibility="Collapsed" IsIndeterminate="True"/>

                    <StackPanel Grid.Row="3" Orientation="Horizontal" Margin="0,12,0,0" HorizontalAlignment="Right">
                        <Button x:Name="BtnRefreshUpdates" Content="↺ Vernieuwen"
                                Style="{StaticResource BtnGhost}" Margin="0,0,8,0"/>
                        <Button x:Name="BtnUpdateSelected" Content="⬆ Selectie updaten"
                                Style="{StaticResource BtnGreen}" Margin="0,0,8,0" IsEnabled="False"/>
                        <Button x:Name="BtnUpdateAll" Content="🚀 Alles updaten"
                                Style="{StaticResource BtnBlue}"/>
                    </StackPanel>
                </Grid>
            </TabItem>

            <!-- ─ Tab 4: Import / Export ─ -->
            <TabItem Header="📂  Import/Export">
                <Grid Margin="30">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="20"/>
                        <ColumnDefinition Width="*"/>
                    </Grid.ColumnDefinitions>

                    <!-- Export -->
                    <Border Grid.Column="0" Background="#313149" CornerRadius="12" Padding="24">
                        <StackPanel>
                            <TextBlock Text="📤  Exporteren" FontSize="16" FontWeight="SemiBold"
                                       Foreground="#89B4FA" Margin="0,0,0,12"/>
                            <TextBlock TextWrapping="Wrap" Foreground="#6C7086" Margin="0,0,0,20"
                                       Text="Sla alle geïnstalleerde packages op in een JSON-bestand. Handig als back-up of om op een andere computer te installeren."/>
                            <Label Content="Exportbestand:"/>
                            <Grid Margin="0,4,0,16">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="Auto"/>
                                </Grid.ColumnDefinitions>
                                <TextBox x:Name="TxtExportPath" Margin="0,0,8,0"
                                         Text="C:\backup\packages.json"/>
                                <Button x:Name="BtnBrowseExport" Grid.Column="1"
                                        Content="..." Style="{StaticResource BtnGhost}" Padding="12,6"/>
                            </Grid>
                            <Button x:Name="BtnExport" Content="⬇ Nu exporteren"
                                    Style="{StaticResource BtnGreen}" HorizontalAlignment="Left"/>
                        </StackPanel>
                    </Border>

                    <!-- Import -->
                    <Border Grid.Column="2" Background="#313149" CornerRadius="12" Padding="24">
                        <StackPanel>
                            <TextBlock Text="📥  Importeren" FontSize="16" FontWeight="SemiBold"
                                       Foreground="#89B4FA" Margin="0,0,0,12"/>
                            <TextBlock TextWrapping="Wrap" Foreground="#6C7086" Margin="0,0,0,20"
                                       Text="Installeer alle packages uit een bestaand JSON-exportbestand. Niet-beschikbare packages worden overgeslagen indien gewenst."/>
                            <Label Content="Importbestand:"/>
                            <Grid Margin="0,4,0,8">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="Auto"/>
                                </Grid.ColumnDefinitions>
                                <TextBox x:Name="TxtImportPath" Margin="0,0,8,0"/>
                                <Button x:Name="BtnBrowseImport" Grid.Column="1"
                                        Content="..." Style="{StaticResource BtnGhost}" Padding="12,6"/>
                            </Grid>
                            <CheckBox x:Name="ChkIgnoreUnavailable" Content="Niet-beschikbare packages overslaan"
                                      IsChecked="True" Margin="0,4,0,16" Foreground="#CDD6F4"/>
                            <Button x:Name="BtnImport" Content="⬆ Nu importeren"
                                    Style="{StaticResource BtnBlue}" HorizontalAlignment="Left"/>
                        </StackPanel>
                    </Border>
                </Grid>
            </TabItem>

            <!-- ─ Tab 5: Bronnen ─ -->
            <TabItem Header="🔗  Bronnen">
                <Grid Margin="20">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <DataGrid x:Name="GridSources" Grid.Row="0" IsReadOnly="True">
                        <DataGrid.Columns>
                            <DataGridTextColumn Header="Naam" Binding="{Binding Name}" Width="150"/>
                            <DataGridTextColumn Header="URL"  Binding="{Binding Url}"  Width="*"/>
                            <DataGridTextColumn Header="Type" Binding="{Binding Type}" Width="180"/>
                        </DataGrid.Columns>
                    </DataGrid>

                    <!-- Nieuwe bron toevoegen -->
                    <Border Grid.Row="1" Background="#313149" CornerRadius="8"
                            Padding="16" Margin="0,16,0,0">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="160"/>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="*"/>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="160"/>
                                <ColumnDefinition Width="Auto"/>
                            </Grid.ColumnDefinitions>
                            <Label Grid.Column="0" Content="Naam:" VerticalAlignment="Center"/>
                            <TextBox x:Name="TxtSourceName" Grid.Column="1" Margin="4,0,12,0"/>
                            <Label Grid.Column="2" Content="URL:" VerticalAlignment="Center"/>
                            <TextBox x:Name="TxtSourceUrl" Grid.Column="3" Margin="4,0,12,0"/>
                            <Label Grid.Column="4" Content="Type:" VerticalAlignment="Center"/>
                            <ComboBox x:Name="CmbSourceType" Grid.Column="5" Margin="4,0,12,0">
                                <ComboBoxItem Content="Microsoft.Rest" IsSelected="True"/>
                                <ComboBoxItem Content="Microsoft.PreIndexed.Package"/>
                            </ComboBox>
                            <Button x:Name="BtnAddSource" Grid.Column="6" Content="➕ Toevoegen"
                                    Style="{StaticResource BtnGreen}"/>
                        </Grid>
                    </Border>

                    <StackPanel Grid.Row="2" Orientation="Horizontal" Margin="0,12,0,0" HorizontalAlignment="Right">
                        <Button x:Name="BtnRefreshSources" Content="↺ Vernieuwen"
                                Style="{StaticResource BtnGhost}" Margin="0,0,8,0"/>
                        <Button x:Name="BtnRemoveSource" Content="🗑 Verwijderen"
                                Style="{StaticResource BtnRed}" Margin="0,0,8,0" IsEnabled="False"/>
                        <Button x:Name="BtnResetSources" Content="↩ Reset standaard"
                                Style="{StaticResource BtnYellow}"/>
                    </StackPanel>
                </Grid>
            </TabItem>

            <!-- ─ Tab 6: Logs ─ -->
            <TabItem Header="📋  Logs">
                <Grid Margin="20">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <StackPanel Grid.Row="0" Orientation="Horizontal" Margin="0,0,0,12">
                        <ComboBox x:Name="CmbLogFilter" Width="120" Margin="0,0,8,0">
                            <ComboBoxItem Content="Alle" IsSelected="True"/>
                            <ComboBoxItem Content="DEBUG"/>
                            <ComboBoxItem Content="INFO"/>
                            <ComboBoxItem Content="WARN"/>
                            <ComboBoxItem Content="ERROR"/>
                        </ComboBox>
                        <Button x:Name="BtnClearLogs" Content="🗑 Wissen"
                                Style="{StaticResource BtnGhost}" Margin="0,0,8,0"/>
                        <Button x:Name="BtnOpenLogFile" Content="📁 Open logbestand"
                                Style="{StaticResource BtnGhost}"/>
                        <TextBlock x:Name="TxtLogPath" Foreground="#6C7086" FontSize="11"
                                   VerticalAlignment="Center" Margin="16,0,0,0"/>
                    </StackPanel>

                    <DataGrid x:Name="GridLogs" Grid.Row="1" IsReadOnly="True"
                              CanUserSortColumns="False" FontFamily="Consolas" FontSize="12">
                        <DataGrid.Columns>
                            <DataGridTextColumn Header="Tijdstip"  Binding="{Binding Timestamp}" Width="180"/>
                            <DataGridTextColumn Header="Level"     Binding="{Binding Level}"     Width="70"/>
                            <DataGridTextColumn Header="Bron"      Binding="{Binding Source}"    Width="120"/>
                            <DataGridTextColumn Header="Bericht"   Binding="{Binding Message}"   Width="*"/>
                        </DataGrid.Columns>
                        <DataGrid.RowStyle>
                            <Style TargetType="DataGridRow">
                                <Style.Triggers>
                                    <DataTrigger Binding="{Binding Level}" Value="ERROR">
                                        <Setter Property="Background" Value="#3D1A1F"/>
                                        <Setter Property="Foreground" Value="#F38BA8"/>
                                    </DataTrigger>
                                    <DataTrigger Binding="{Binding Level}" Value="WARN">
                                        <Setter Property="Background" Value="#3D320A"/>
                                        <Setter Property="Foreground" Value="#F9E2AF"/>
                                    </DataTrigger>
                                    <DataTrigger Binding="{Binding Level}" Value="DEBUG">
                                        <Setter Property="Foreground" Value="#6C7086"/>
                                    </DataTrigger>
                                </Style.Triggers>
                            </Style>
                        </DataGrid.RowStyle>
                    </DataGrid>
                </Grid>
            </TabItem>

            <!-- ─ Tab 7: Instellingen ─ -->
            <TabItem Header="⚙  Instellingen">
                <ScrollViewer Margin="20" VerticalScrollBarVisibility="Auto">
                    <StackPanel MaxWidth="600" HorizontalAlignment="Left">

                        <TextBlock Text="Logging" FontSize="15" FontWeight="SemiBold"
                                   Foreground="#89B4FA" Margin="0,0,0,12"/>

                        <Grid Margin="0,0,0,8">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="200"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>
                            <Label Content="Log-map:" VerticalAlignment="Center"/>
                            <TextBox x:Name="TxtSettingsLogDir" Grid.Column="1"/>
                        </Grid>
                        <Grid Margin="0,0,0,8">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="200"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>
                            <Label Content="Minimaal niveau:" VerticalAlignment="Center"/>
                            <ComboBox x:Name="CmbSettingsLogLevel" Grid.Column="1">
                                <ComboBoxItem Content="DEBUG"/>
                                <ComboBoxItem Content="INFO" IsSelected="True"/>
                                <ComboBoxItem Content="WARN"/>
                                <ComboBoxItem Content="ERROR"/>
                            </ComboBox>
                        </Grid>
                        <Grid Margin="0,0,0,24">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="200"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>
                            <Label Content="Bewaarperiode (dagen):" VerticalAlignment="Center"/>
                            <TextBox x:Name="TxtSettingsRetention" Grid.Column="1" Text="30"/>
                        </Grid>

                        <TextBlock Text="Gedrag" FontSize="15" FontWeight="SemiBold"
                                   Foreground="#89B4FA" Margin="0,0,0,12"/>

                        <Grid Margin="0,0,0,8">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="200"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>
                            <Label Content="Standaard scope:" VerticalAlignment="Center"/>
                            <ComboBox x:Name="CmbSettingsScope" Grid.Column="1">
                                <ComboBoxItem Content="user" IsSelected="True"/>
                                <ComboBoxItem Content="machine"/>
                            </ComboBox>
                        </Grid>

                        <CheckBox x:Name="ChkAutoUpdateCheck"
                                  Content="Controleer updates bij opstarten"
                                  IsChecked="True" Margin="0,4,0,4"/>
                        <CheckBox x:Name="ChkConfirmUninstall"
                                  Content="Bevestiging vragen bij verwijderen"
                                  IsChecked="True" Margin="0,4,0,4"/>
                        <CheckBox x:Name="ChkConfirmUpdate"
                                  Content="Bevestiging vragen bij updaten"
                                  IsChecked="False" Margin="0,4,0,24"/>

                        <TextBlock Text="Zelf-update" FontSize="15" FontWeight="SemiBold"
                                   Foreground="#89B4FA" Margin="0,0,0,12"/>

                        <Grid Margin="0,0,0,24">
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="200"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>
                            <Label Content="Update URL:" VerticalAlignment="Center"/>
                            <TextBox x:Name="TxtSettingsUpdateUrl" Grid.Column="1"/>
                        </Grid>

                        <StackPanel Orientation="Horizontal">
                            <Button x:Name="BtnSaveSettings" Content="💾 Opslaan"
                                    Style="{StaticResource BtnGreen}" Margin="0,0,8,0"/>
                            <Button x:Name="BtnResetSettings" Content="↩ Standaard herstellen"
                                    Style="{StaticResource BtnGhost}"/>
                        </StackPanel>
                    </StackPanel>
                </ScrollViewer>
            </TabItem>

        </TabControl>

        <!-- ── Statusbalk ────────────────────────────────────────────── -->
        <Border Grid.Row="2" Background="#313149" BorderBrush="#45475A" BorderThickness="0,1,0,0">
            <Grid Margin="16,0">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="180"/>
                </Grid.ColumnDefinitions>

                <TextBlock x:Name="TxtStatus" Text="Gereed" Foreground="#6C7086"
                           FontSize="12" VerticalAlignment="Center"/>
                <ProgressBar x:Name="StatusProgress" Grid.Column="1"
                             Width="150" Height="4" Margin="0,0,16,0"
                             Visibility="Collapsed" IsIndeterminate="True"/>
                <TextBlock x:Name="TxtWinGetVersionStatus" Grid.Column="2"
                           FontSize="11" Foreground="#6C7086" VerticalAlignment="Center"
                           HorizontalAlignment="Right"/>
            </Grid>
        </Border>

    </Grid>
</Window>
'@

# ---------------------------------------------------------------------------
# Window laden
# ---------------------------------------------------------------------------

$Reader = [System.Xml.XmlNodeReader]::new($Xaml)
$Window = [System.Windows.Markup.XamlReader]::Load($Reader)

# Helpers voor control-lookup
function Get-Control { param($name) $Window.FindName($name) }

$TxtSearch               = Get-Control 'TxtSearch'
$CmbSearchSource         = Get-Control 'CmbSearchSource'
$BtnSearch               = Get-Control 'BtnSearch'
$BtnClearSearch          = Get-Control 'BtnClearSearch'
$GridSearch              = Get-Control 'GridSearch'
$BtnInstallSelected      = Get-Control 'BtnInstallSelected'
$BtnShowDetails          = Get-Control 'BtnShowDetails'

$TxtFilterInstalled      = Get-Control 'TxtFilterInstalled'
$BtnRefreshInstalled     = Get-Control 'BtnRefreshInstalled'
$GridInstalled           = Get-Control 'GridInstalled'
$TxtInstalledCount       = Get-Control 'TxtInstalledCount'
$BtnUninstallSelected    = Get-Control 'BtnUninstallSelected'
$BtnUpdateSelectedInstalled = Get-Control 'BtnUpdateSelectedInstalled'

$GridUpdates             = Get-Control 'GridUpdates'
$TxtUpdateCount          = Get-Control 'TxtUpdateCount'
$TxtWinGetVersion        = Get-Control 'TxtWinGetVersion'
$UpdateProgress          = Get-Control 'UpdateProgress'
$BtnRefreshUpdates       = Get-Control 'BtnRefreshUpdates'
$BtnUpdateSelected       = Get-Control 'BtnUpdateSelected'
$BtnUpdateAll            = Get-Control 'BtnUpdateAll'

$TxtExportPath           = Get-Control 'TxtExportPath'
$BtnBrowseExport         = Get-Control 'BtnBrowseExport'
$BtnExport               = Get-Control 'BtnExport'
$TxtImportPath           = Get-Control 'TxtImportPath'
$BtnBrowseImport         = Get-Control 'BtnBrowseImport'
$ChkIgnoreUnavailable    = Get-Control 'ChkIgnoreUnavailable'
$BtnImport               = Get-Control 'BtnImport'

$GridSources             = Get-Control 'GridSources'
$TxtSourceName           = Get-Control 'TxtSourceName'
$TxtSourceUrl            = Get-Control 'TxtSourceUrl'
$CmbSourceType           = Get-Control 'CmbSourceType'
$BtnAddSource            = Get-Control 'BtnAddSource'
$BtnRefreshSources       = Get-Control 'BtnRefreshSources'
$BtnRemoveSource         = Get-Control 'BtnRemoveSource'
$BtnResetSources         = Get-Control 'BtnResetSources'

$GridLogs                = Get-Control 'GridLogs'
$CmbLogFilter            = Get-Control 'CmbLogFilter'
$BtnClearLogs            = Get-Control 'BtnClearLogs'
$BtnOpenLogFile          = Get-Control 'BtnOpenLogFile'
$TxtLogPath              = Get-Control 'TxtLogPath'

$TxtSettingsLogDir       = Get-Control 'TxtSettingsLogDir'
$CmbSettingsLogLevel     = Get-Control 'CmbSettingsLogLevel'
$TxtSettingsRetention    = Get-Control 'TxtSettingsRetention'
$CmbSettingsScope        = Get-Control 'CmbSettingsScope'
$ChkAutoUpdateCheck      = Get-Control 'ChkAutoUpdateCheck'
$ChkConfirmUninstall     = Get-Control 'ChkConfirmUninstall'
$ChkConfirmUpdate        = Get-Control 'ChkConfirmUpdate'
$TxtSettingsUpdateUrl    = Get-Control 'TxtSettingsUpdateUrl'
$BtnSaveSettings         = Get-Control 'BtnSaveSettings'
$BtnResetSettings        = Get-Control 'BtnResetSettings'

$TxtStatus               = Get-Control 'TxtStatus'
$StatusProgress          = Get-Control 'StatusProgress'
$TxtWinGetVersionStatus  = Get-Control 'TxtWinGetVersionStatus'
$TxtAppVersion           = Get-Control 'TxtAppVersion'
$AdminBadge              = Get-Control 'AdminBadge'
$BtnCheckUpdates         = Get-Control 'BtnCheckUpdates'
$BtnSelfUpdate           = Get-Control 'BtnSelfUpdate'

# ---------------------------------------------------------------------------
# Hulpfuncties UI-thread
# ---------------------------------------------------------------------------

function Set-Status {
    param([string]$Text, [bool]$Busy = $false)
    $Window.Dispatcher.Invoke([action]{
        $TxtStatus.Text = $Text
        $StatusProgress.Visibility = if ($Busy) { 'Visible' } else { 'Collapsed' }
    })
}

function Set-UIEnabled {
    param([bool]$Enabled)
    $Window.Dispatcher.Invoke([action]{
        $Window.IsEnabled = $Enabled
    })
}

function Show-Info  { param($msg) [System.Windows.MessageBox]::Show($msg, "Info",    "OK", "Information") | Out-Null }
function Show-Error { param($msg) [System.Windows.MessageBox]::Show($msg, "Fout",    "OK", "Error")       | Out-Null }
function Ask-Confirm { param($msg) ([System.Windows.MessageBox]::Show($msg, "Bevestig", "YesNo", "Question")) -eq 'Yes' }

# Start een winget-commando in achtergrond-runspace zodat de GUI niet bevriest
function Start-WinGetWork {
    param(
        [Parameter(Mandatory)][string[]]$WinGetArgs,
        [string]$BusyMessage = "Bezig...",
        [Parameter(Mandatory)][scriptblock]$OnDone   # ($exitCode, $output) op UI-thread
    )

    Set-Status $BusyMessage $true
    $Window.IsEnabled = $false

    $rs = [runspacefactory]::CreateRunspace()
    $rs.ApartmentState = 'STA'
    $rs.Open()
    $ps = [powershell]::Create()
    $ps.Runspace = $rs
    [void]$ps.AddScript({
        param($a)
        $output = & winget @a 2>&1 | Out-String
        return [PSCustomObject]@{ ExitCode = $LASTEXITCODE; Output = $output }
    }).AddArgument($WinGetArgs)
    $handle = $ps.BeginInvoke()

    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromMilliseconds(300)

    $tickHandler = {
        if ($handle.IsCompleted) {
            $timer.Stop()
            $exit = -1; $output = ''
            try {
                $r = $ps.EndInvoke($handle) | Select-Object -First 1
                if ($r) { $exit = [int]$r.ExitCode; $output = "$($r.Output)" }
            } catch {
                Write-Log "Async fout: $_" -Level ERROR -Source GUI
            } finally {
                $ps.Dispose(); $rs.Dispose()
            }
            $Window.IsEnabled = $true
            try { & $OnDone $exit $output } catch { Write-Log "OnDone fout: $_" -Level ERROR -Source GUI }
        }
    }.GetNewClosure()

    $timer.Add_Tick($tickHandler)
    $timer.Start()
}

function Run-Async {
    param([scriptblock]$Work, [scriptblock]$OnDone = {})
    $rs = [runspacefactory]::CreateRunspace()
    $rs.ApartmentState = 'STA'
    $rs.ThreadOptions  = 'ReuseThread'
    $rs.Open()

    $rs.SessionStateProxy.SetVariable('ScriptRoot',     $ScriptRoot)
    $rs.SessionStateProxy.SetVariable('Dispatcher',     $Window.Dispatcher)
    $rs.SessionStateProxy.SetVariable('LogCollection',  $LogCollection)
    $rs.SessionStateProxy.SetVariable('cfg',            $cfg)

    $ps = [powershell]::Create()
    $ps.Runspace = $rs

    $init = {
        Import-Module "$ScriptRoot\src\Core\Logging.psm1"     -Force
        Import-Module "$ScriptRoot\src\Core\Config.psm1"      -Force
        Import-Module "$ScriptRoot\src\Core\WinGet-Core.psm1" -Force
        Initialize-WinGetCore -WinGetPath $cfg.WinGetPath
        Set-LogObservable $LogCollection
    }
    $null = $ps.AddScript($init).AddScript($Work)
    $handle = $ps.BeginInvoke()

    $timer = [System.Windows.Threading.DispatcherTimer]::new()
    $timer.Interval = [TimeSpan]::FromMilliseconds(200)
    $timer.Add_Tick({
        if ($handle.IsCompleted) {
            $timer.Stop()
            try   { $ps.EndInvoke($handle) }
            catch { Write-Log "Async fout: $_" -Level ERROR -Source GUI }
            $ps.Dispose(); $rs.Dispose()
            $Window.Dispatcher.Invoke($OnDone)
        }
    })
    $timer.Start()
}

# ---------------------------------------------------------------------------
# Initialisatie UI-waarden
# ---------------------------------------------------------------------------

$TxtAppVersion.Text           = "v$(Get-AppVersion)"
$TxtWinGetVersionStatus.Text  = "WinGet v$(Get-WinGetVersion)"
$TxtLogPath.Text              = Get-LogPath

if (Test-IsAdmin) { $AdminBadge.Visibility = 'Visible' }

# Instellingen laden
$TxtSettingsLogDir.Text      = $cfg.LogDirectory
$TxtSettingsRetention.Text   = $cfg.LogRetentionDays
$TxtSettingsUpdateUrl.Text   = $cfg.SelfUpdateUrl
$ChkAutoUpdateCheck.IsChecked   = [bool]$cfg.AutoUpdateCheckOnStart
$ChkConfirmUninstall.IsChecked  = [bool]$cfg.ConfirmUninstall
$ChkConfirmUpdate.IsChecked     = [bool]$cfg.ConfirmUpdate

# Selecteer juiste ComboBox items
foreach ($item in $CmbSettingsLogLevel.Items) {
    if ($item.Content -eq $cfg.LogLevel) { $CmbSettingsLogLevel.SelectedItem = $item; break }
}
foreach ($item in $CmbSettingsScope.Items) {
    if ($item.Content -eq $cfg.DefaultScope) { $CmbSettingsScope.SelectedItem = $item; break }
}

# Log binding
$GridLogs.ItemsSource = $LogCollection

Write-Log "GUI geladen" -Source GUI
Write-Log "WinGet versie: $(Get-WinGetVersion)" -Source GUI
Write-Log "App versie: $(Get-AppVersion)" -Source GUI
Write-Log "Admin: $(Test-IsAdmin)" -Source GUI

# ---------------------------------------------------------------------------
# Zoekfunctionaliteit
# ---------------------------------------------------------------------------

$BtnSearch.Add_Click({
    $query = $TxtSearch.Text.Trim()
    if (-not $query) { return }

    Set-Status "Zoeken naar '$query'..." $true
    $GridSearch.ItemsSource = $null

    $src = $CmbSearchSource.SelectedItem.Content
    if ($src -eq 'Alle bronnen') { $src = $null }

    Run-Async -Work ([scriptblock]::Create("
        `$results = Search-WinGetPackage -Query '$($query -replace "'","''")' $(if($src){"-Source '$src'"})
        `$Dispatcher.Invoke([action]{ `$args[0] }, `$results)
    ")) -OnDone {
        Set-Status "Gereed"
    }

    # Directe aanroep (simpeler dan async voor UI-updates)
    $GridSearch.ItemsSource = $null
    Set-Status "Zoeken..." $true
    try {
        $src2    = if ($src) { $src } else { $null }
        $results = Search-WinGetPackage -Query $query -Source $src2
        $GridSearch.ItemsSource = $results
        Set-Status "$($results.Count) resultaten gevonden"
        Write-Log "Zoekresultaten: $($results.Count) voor '$query'" -Source GUI
    } catch {
        Set-Status "Zoekfout"
        Show-Error "Zoeken mislukt: $_"
        Write-Log "Zoekfout: $_" -Level ERROR -Source GUI
    }
})

$TxtSearch.Add_KeyDown({
    if ($_.Key -eq 'Return') { $BtnSearch.RaiseEvent([System.Windows.RoutedEventArgs]::new([System.Windows.Controls.Button]::ClickEvent)) }
})

$BtnClearSearch.Add_Click({
    $TxtSearch.Text     = ''
    $GridSearch.ItemsSource = $null
    Set-Status "Gereed"
})

$GridSearch.Add_SelectionChanged({
    $BtnInstallSelected.IsEnabled = $GridSearch.SelectedItem -ne $null
    $BtnShowDetails.IsEnabled     = $GridSearch.SelectedItem -ne $null
})

$BtnInstallSelected.Add_Click({
    $pkg = $GridSearch.SelectedItem
    if (-not $pkg) { return }
    if (-not (Ask-Confirm "Installeer '$($pkg.Name)' ($($pkg.Id))?")) { return }

    $name = $pkg.Name; $id = $pkg.Id
    $args = @('install','--id',$id,'--exact','--scope',$cfg.DefaultScope,
              '--silent','--accept-source-agreements','--accept-package-agreements','--disable-interactivity')

    Start-WinGetWork -WinGetArgs $args -BusyMessage "Installeren: $name..." -OnDone {
        param($exit, $output)
        if ($exit -eq 0) {
            Show-Info "'$name' succesvol geinstalleerd."
            Set-Status "Installatie geslaagd"
            Refresh-Installed
        } else {
            Show-Error "Installatie mislukt (code $exit)"
            Set-Status "Installatie mislukt"
        }
    }.GetNewClosure()
})

$BtnShowDetails.Add_Click({
    $pkg = $GridSearch.SelectedItem
    if (-not $pkg) { return }
    Set-Status "Details ophalen..." $true
    try {
        $info = Get-WinGetPackageInfo -Id $pkg.Id
        $msg  = "Naam:    $($info.Name)`nID:      $($info.Id)`nVersie:  $($info.Version)`nUitgever: $($info.Publisher)`nBron:    $($info.Source)"
        [System.Windows.MessageBox]::Show($msg, "Package details", "OK", "Information") | Out-Null
        Set-Status "Gereed"
    } catch {
        Set-Status "Fout bij details"
    }
})

# ---------------------------------------------------------------------------
# Geïnstalleerde packages
# ---------------------------------------------------------------------------

$Script:AllInstalled = @()

function Refresh-Installed {
    Set-Status "Geïnstalleerde packages laden..." $true
    $GridInstalled.ItemsSource = $null
    try {
        $installed = Get-WinGetInstalled
        $updates   = @()
        try { $updates = Get-WinGetUpdates } catch { Write-Log "Updates ophalen mislukt: $_" -Level WARN -Source GUI }

        # Index updates op Id voor snelle lookup
        $updateMap = @{}
        foreach ($u in $updates) {
            if ($u.Id) { $updateMap[$u.Id] = $u }
        }

        # Verrijk installed met AvailableVersion + HasUpdate vlag
        $merged = foreach ($pkg in $installed) {
            $avail = ''
            $hasUpdate = $false
            if ($pkg.Id -and $updateMap.ContainsKey($pkg.Id)) {
                $avail = $updateMap[$pkg.Id].AvailableVersion
                if ($avail -and $avail -ne $pkg.Version) { $hasUpdate = $true }
            }
            [PSCustomObject]@{
                Name             = $pkg.Name
                Id               = $pkg.Id
                Version          = $pkg.Version
                AvailableVersion = $avail
                Source           = $pkg.Source
                HasUpdate        = $hasUpdate
            }
        }

        $Script:AllInstalled = @($merged)
        Apply-InstalledFilter
        $upgradable = @($Script:AllInstalled | Where-Object { $_.HasUpdate }).Count
        $TxtInstalledCount.Text = "$($Script:AllInstalled.Count) packages, $upgradable updatebaar"
        Write-Log "Geïnstalleerd geladen: $($Script:AllInstalled.Count) ($upgradable met update)" -Source GUI
        Set-Status "Gereed"
    } catch {
        Set-Status "Fout"
        Show-Error "Laden mislukt: $_"
        Write-Log "Laden geïnstalleerd mislukt: $_" -Level ERROR -Source GUI
    }
}

function Apply-InstalledFilter {
    $filter = $TxtFilterInstalled.Text.Trim().ToLower()
    if (-not $filter) {
        $GridInstalled.ItemsSource = $Script:AllInstalled
    } else {
        $GridInstalled.ItemsSource = $Script:AllInstalled | Where-Object {
            $_.Name -like "*$filter*" -or $_.Id -like "*$filter*"
        }
    }
}

$BtnRefreshInstalled.Add_Click({ Refresh-Installed })
$TxtFilterInstalled.Add_TextChanged({ Apply-InstalledFilter })

$GridInstalled.Add_SelectionChanged({
    $pkg = $GridInstalled.SelectedItem
    $BtnUninstallSelected.IsEnabled = ($pkg -ne $null)
    $BtnUpdateSelectedInstalled.IsEnabled = ($pkg -ne $null -and $pkg.HasUpdate)
})

$BtnUninstallSelected.Add_Click({
    $pkg = $GridInstalled.SelectedItem
    if (-not $pkg) { return }
    if ($cfg.ConfirmUninstall -and -not (Ask-Confirm "Verwijder '$($pkg.Name)'?")) { return }

    $name = $pkg.Name; $id = $pkg.Id
    $args = @('uninstall','--id',$id,'--exact','--silent','--disable-interactivity')

    Start-WinGetWork -WinGetArgs $args -BusyMessage "Verwijderen: $name..." -OnDone {
        param($exit, $output)
        if ($exit -eq 0) {
            Set-Status "Verwijderd"
            Refresh-Installed
        } else {
            Show-Error "Verwijderen mislukt (code $exit)"
            Set-Status "Mislukt"
        }
    }.GetNewClosure()
})

$BtnUpdateSelectedInstalled.Add_Click({
    $pkg = $GridInstalled.SelectedItem
    if (-not $pkg) { return }

    $name = $pkg.Name; $id = $pkg.Id
    $args = @('upgrade','--id',$id,'--exact','--silent',
              '--accept-source-agreements','--accept-package-agreements','--disable-interactivity')

    Start-WinGetWork -WinGetArgs $args -BusyMessage "Updaten: $name..." -OnDone {
        param($exit, $output)
        if ($exit -eq 0) {
            Set-Status "Update van $name geslaagd"
            Refresh-Installed
        } else {
            Show-Error "Update van $name mislukt (code $exit)"
            Set-Status "Update mislukt"
        }
    }.GetNewClosure()
})

# ---------------------------------------------------------------------------
# Updates tab
# ---------------------------------------------------------------------------

$Script:UpdateablePackages = @()

function Refresh-Updates {
    Set-Status "Updates controleren..." $true
    $TxtUpdateCount.Text = "..."
    $GridUpdates.ItemsSource = $null
    try {
        $raw = Get-WinGetUpdates
        $Script:UpdateablePackages = $raw | ForEach-Object {
            $_ | Add-Member -NotePropertyName Selected -NotePropertyValue $false -PassThru
        }
        $GridUpdates.ItemsSource = $Script:UpdateablePackages
        $TxtUpdateCount.Text     = $Script:UpdateablePackages.Count
        $TxtWinGetVersion.Text   = Get-WinGetVersion
        $BtnUpdateSelected.IsEnabled = $Script:UpdateablePackages.Count -gt 0
        Set-Status "$(($Script:UpdateablePackages).Count) update(s) gevonden"
        Write-Log "Updates: $($Script:UpdateablePackages.Count)" -Source GUI
    } catch {
        Set-Status "Fout bij controleren"
        $TxtUpdateCount.Text = "!"
        Write-Log "Update-check fout: $_" -Level ERROR -Source GUI
    }
}

$BtnRefreshUpdates.Add_Click({ Refresh-Updates })

$BtnUpdateAll.Add_Click({
    $count = $Script:UpdateablePackages.Count
    if ($count -eq 0) { Show-Info "Geen updates beschikbaar."; return }
    if (-not (Ask-Confirm "Alle $count packages updaten?")) { return }

    $UpdateProgress.Visibility = 'Visible'
    $args = @('upgrade','--all','--silent',
              '--accept-source-agreements','--accept-package-agreements','--disable-interactivity')

    Start-WinGetWork -WinGetArgs $args -BusyMessage "Alle packages updaten..." -OnDone {
        param($exit, $output)
        $UpdateProgress.Visibility = 'Collapsed'
        Refresh-Updates
        Refresh-Installed
        if ($exit -eq 0) {
            Show-Info "Alle updates afgerond."
            Set-Status "Klaar"
        } else {
            Show-Error "Sommige updates zijn mislukt (code $exit). Zie logs."
            Set-Status "Update klaar (met fouten)"
        }
    }.GetNewClosure()
})

$BtnUpdateSelected.Add_Click({
    $selected = @($Script:UpdateablePackages | Where-Object { $_.Selected })
    if ($selected.Count -eq 0) {
        Show-Info "Selecteer eerst packages via het selectievakje."
        return
    }
    if (-not (Ask-Confirm "$($selected.Count) geselecteerde package(s) updaten?")) { return }

    $UpdateProgress.Visibility = 'Visible'
    Set-Status "Geselecteerde updaten..." $true
    $Window.IsEnabled = $false

    $ids = @($selected | ForEach-Object { $_.Id })

    $rs = [runspacefactory]::CreateRunspace()
    $rs.Open()
    $ps = [powershell]::Create()
    $ps.Runspace = $rs
    [void]$ps.AddScript({
        param($idList)
        $ok = 0; $fail = 0
        foreach ($id in $idList) {
            $a = @('upgrade','--id',$id,'--exact','--silent',
                   '--accept-source-agreements','--accept-package-agreements','--disable-interactivity')
            $null = & winget @a 2>&1
            if ($LASTEXITCODE -eq 0) { $ok++ } else { $fail++ }
        }
        return [PSCustomObject]@{ Ok = $ok; Fail = $fail }
    }).AddArgument($ids)
    $handle = $ps.BeginInvoke()

    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromMilliseconds(500)
    $timer.Add_Tick({
        if ($handle.IsCompleted) {
            $timer.Stop()
            $okCount = 0; $failCount = 0
            try {
                $r = $ps.EndInvoke($handle) | Select-Object -First 1
                if ($r) { $okCount = $r.Ok; $failCount = $r.Fail }
            } catch {}
            $ps.Dispose(); $rs.Dispose()
            $UpdateProgress.Visibility = 'Collapsed'
            $Window.IsEnabled = $true
            Refresh-Updates
            Refresh-Installed
            Set-Status "Klaar: $okCount geslaagd, $failCount mislukt"
        }
    }.GetNewClosure())
    $timer.Start()
})

# ---------------------------------------------------------------------------
# Import / Export
# ---------------------------------------------------------------------------

$BtnBrowseExport.Add_Click({
    $dlg = [Microsoft.Win32.SaveFileDialog]::new()
    $dlg.Filter        = "JSON bestanden (*.json)|*.json"
    $dlg.DefaultExt    = "json"
    $dlg.FileName      = "winget-packages-$(Get-Date -Format 'yyyy-MM-dd')"
    if ($dlg.ShowDialog()) { $TxtExportPath.Text = $dlg.FileName }
})

$BtnBrowseImport.Add_Click({
    $dlg = [Microsoft.Win32.OpenFileDialog]::new()
    $dlg.Filter = "JSON bestanden (*.json)|*.json"
    if ($dlg.ShowDialog()) { $TxtImportPath.Text = $dlg.FileName }
})

$BtnExport.Add_Click({
    $path = $TxtExportPath.Text.Trim()
    if (-not $path) { Show-Info "Geef een exportpad op."; return }
    Set-Status "Exporteren..." $true
    try {
        $ok = Export-WinGetPackages -OutputPath $path
        if ($ok) { Show-Info "Export geslaagd naar:`n$path" } else { Show-Error "Export mislukt." }
        Set-Status $(if($ok){"Export geslaagd"}else{"Export mislukt"})
    } catch {
        Show-Error "Fout: $_"
        Set-Status "Fout"
    }
})

$BtnImport.Add_Click({
    $path = $TxtImportPath.Text.Trim()
    if (-not $path -or -not (Test-Path $path)) { Show-Info "Geldig importbestand selecteren."; return }
    if (-not (Ask-Confirm "Alle packages uit '$path' installeren?")) { return }
    Set-Status "Importeren..." $true
    try {
        $ok = Import-WinGetPackages -InputPath $path -IgnoreUnavailable:$ChkIgnoreUnavailable.IsChecked
        if ($ok) { Show-Info "Import geslaagd." } else { Show-Error "Import mislukt (sommige packages konden niet worden geïnstalleerd)." }
        Set-Status $(if($ok){"Import geslaagd"}else{"Import klaar (met fouten)"})
    } catch {
        Show-Error "Fout: $_"
        Set-Status "Fout"
    }
})

# ---------------------------------------------------------------------------
# Bronnen
# ---------------------------------------------------------------------------

function Refresh-Sources {
    $GridSources.ItemsSource = $null
    try {
        $GridSources.ItemsSource = Get-WinGetSources
        Set-Status "Bronnen geladen"
    } catch {
        Write-Log "Bronnen laden mislukt: $_" -Level ERROR -Source GUI
    }
}

$BtnRefreshSources.Add_Click({ Refresh-Sources })

$GridSources.Add_SelectionChanged({
    $BtnRemoveSource.IsEnabled = $GridSources.SelectedItem -ne $null
})

$BtnAddSource.Add_Click({
    $name = $TxtSourceName.Text.Trim()
    $url  = $TxtSourceUrl.Text.Trim()
    $type = $CmbSourceType.SelectedItem.Content
    if (-not $name -or -not $url) { Show-Info "Naam en URL zijn verplicht."; return }
    Set-Status "Bron toevoegen..." $true
    try {
        $ok = Add-WinGetSource -Name $name -Url $url -Type $type
        if ($ok) {
            $TxtSourceName.Text = ''; $TxtSourceUrl.Text = ''
            Refresh-Sources
        } else {
            Show-Error "Bron toevoegen mislukt (vereist administrator-rechten)."
        }
        Set-Status $(if($ok){"Bron toegevoegd"}else{"Mislukt"})
    } catch {
        Show-Error "Fout: $_"; Set-Status "Fout"
    }
})

$BtnRemoveSource.Add_Click({
    $src = $GridSources.SelectedItem
    if (-not $src) { return }
    if (-not (Ask-Confirm "Bron '$($src.Name)' verwijderen?")) { return }
    try {
        $ok = Remove-WinGetSource -Name $src.Name
        if ($ok) { Refresh-Sources } else { Show-Error "Verwijderen mislukt (administrator vereist)." }
    } catch {
        Show-Error "Fout: $_"
    }
})

$BtnResetSources.Add_Click({
    if (-not (Ask-Confirm "Alle bronnen resetten naar standaard (vereist administrator)?")) { return }
    try {
        $ok = Reset-WinGetSources
        if ($ok) { Refresh-Sources; Show-Info "Bronnen gereset." } else { Show-Error "Reset mislukt." }
    } catch {
        Show-Error "Fout: $_"
    }
})

# ---------------------------------------------------------------------------
# Logs
# ---------------------------------------------------------------------------

$CmbLogFilter.Add_SelectionChanged({
    $filter = $CmbLogFilter.SelectedItem.Content
    if ($filter -eq 'Alle') {
        $GridLogs.ItemsSource = $LogCollection
    } else {
        $view = [System.Windows.Data.CollectionViewSource]::GetDefaultView($LogCollection)
        $view.Filter = [Predicate[object]]{ param($item) $item.Level -eq $filter }
        $GridLogs.ItemsSource = $view
    }
})

$BtnClearLogs.Add_Click({
    if (Ask-Confirm "Alle logregels verwijderen uit het scherm?") {
        $LogCollection.Clear()
    }
})

$BtnOpenLogFile.Add_Click({
    $logPath = Get-LogPath
    if ($logPath -and (Test-Path $logPath)) {
        Start-Process notepad.exe -ArgumentList $logPath
    } else {
        Show-Info "Logbestand niet gevonden: $logPath"
    }
})

# Auto-scroll logs
$LogCollection.Add_CollectionChanged({
    if ($GridLogs.Items.Count -gt 0) {
        try { $GridLogs.ScrollIntoView($GridLogs.Items[$GridLogs.Items.Count - 1]) } catch {}
    }
})

# ---------------------------------------------------------------------------
# Instellingen opslaan
# ---------------------------------------------------------------------------

$BtnSaveSettings.Add_Click({
    try {
        Set-ConfigValue -Key 'LogDirectory'           -Value $TxtSettingsLogDir.Text.Trim()
        Set-ConfigValue -Key 'LogLevel'               -Value $CmbSettingsLogLevel.SelectedItem.Content
        Set-ConfigValue -Key 'LogRetentionDays'       -Value ([int]$TxtSettingsRetention.Text)
        Set-ConfigValue -Key 'DefaultScope'           -Value $CmbSettingsScope.SelectedItem.Content
        Set-ConfigValue -Key 'AutoUpdateCheckOnStart' -Value $ChkAutoUpdateCheck.IsChecked
        Set-ConfigValue -Key 'ConfirmUninstall'       -Value $ChkConfirmUninstall.IsChecked
        Set-ConfigValue -Key 'ConfirmUpdate'          -Value $ChkConfirmUpdate.IsChecked
        Set-ConfigValue -Key 'SelfUpdateUrl'          -Value $TxtSettingsUpdateUrl.Text.Trim()
        $script:cfg = Get-AppConfig
        Show-Info "Instellingen opgeslagen."
        Write-Log "Instellingen opgeslagen" -Source GUI
    } catch {
        Show-Error "Opslaan mislukt: $_"
    }
})

$BtnResetSettings.Add_Click({
    if (Ask-Confirm "Standaardinstellingen herstellen?") {
        $defaultJson = Join-Path $ScriptRoot 'config\settings.json'
        Initialize-Config -ConfigPath $defaultJson
        $script:cfg = Get-AppConfig
        Show-Info "Standaardinstellingen hersteld. Herstart de app om alle wijzigingen toe te passen."
    }
})

# ---------------------------------------------------------------------------
# Header knoppen
# ---------------------------------------------------------------------------

$BtnCheckUpdates.Add_Click({ Refresh-Updates; (Get-Control 'MainTabs').SelectedIndex = 2 })

$BtnSelfUpdate.Add_Click({
    Set-Status "Controleren op app-update..." $true
    try {
        $updated = Update-App -Url $cfg.SelfUpdateUrl
        if ($updated) {
            Show-Info "Nieuwe versie gedownload. Herstart de app."
        } else {
            Show-Info "App is al up-to-date (v$(Get-AppVersion))."
        }
        Set-Status "Gereed"
    } catch {
        Show-Error "Zelf-update mislukt: $_"
        Set-Status "Fout"
    }
})

# ---------------------------------------------------------------------------
# Opstarten: data laden
# ---------------------------------------------------------------------------

$Window.Add_Loaded({
    Write-Log "Venster geladen, initialisatie starten" -Source GUI

    $TxtWinGetVersionStatus.Text = "WinGet v$(Get-WinGetVersion)"

    Refresh-Installed
    Refresh-Sources

    if ($cfg.AutoUpdateCheckOnStart) {
        Refresh-Updates
    }
})

# ---------------------------------------------------------------------------
# Toon venster
# ---------------------------------------------------------------------------

# Window-icoon instellen (voor titelbalk + taakbalk)
$iconCandidate = Join-Path $ScriptRoot 'assets\icon.ico'
if (Test-Path $iconCandidate) {
    try {
        $iconUri = New-Object System.Uri ((Resolve-Path $iconCandidate).Path)
        $Window.Icon = [System.Windows.Media.Imaging.BitmapFrame]::Create($iconUri)
    } catch {
        Write-Log "Icoon laden mislukt: $_" -Level WARN -Source GUI
    }
}

Write-Log "WinGet Manager GUI starten" -Source GUI
$null = $Window.ShowDialog()
Write-Log "GUI gesloten" -Source GUI

# SIG # Begin signature block
# MIIFggYJKoZIhvcNAQcCoIIFczCCBW8CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU1YjBt7USKSwxKtUCXFyb2SPx
# 5QygggMWMIIDEjCCAfqgAwIBAgIQERy/5noS0YNDQ+ns6effbDANBgkqhkiG9w0B
# AQsFADAhMR8wHQYDVQQDDBZXaW5HZXRNYW5hZ2VyIExvY2FsRGV2MB4XDTI2MDUw
# NTE2NDgxOVoXDTM2MDUwNTE2NTgxOVowITEfMB0GA1UEAwwWV2luR2V0TWFuYWdl
# ciBMb2NhbERldjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJ807LAn
# KDnHe2OML2epBu8NQPQJcoungebjGrM9Sls7qYoaHxPzIwAn5O6NcjyPeBT27nFl
# eQD5HRtffpch5eH8G6weLo/GMmx6z9xWXYEuCqWbzaqcoyYcBTcbwvuz5rOHVxe1
# h4V577zRq5fMxI4oHkneX1/nc36IQznorEvflz86FAw3TwodaT4E7Gw/xH7EQ1MO
# UCwCpsZDdKvZdSrEzgpnFmHqbhjCsOBQLVVoYud0syXosGBQt9JwwaZvp3mQvoJu
# rch0yTuMCIlc46dkecMF4k6xxnXWSifCG+/qqJwYesgRdshr7BqRfXfhJBifREJe
# P6a2k+5RSuScq6kCAwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoG
# CCsGAQUFBwMDMB0GA1UdDgQWBBTB/nzy91KscDO0MblJ8J7M61u28DANBgkqhkiG
# 9w0BAQsFAAOCAQEAUfMEGcqt3OmRMubGOQ7UP9GnMDHV6V74QDFa5Za2hcLCH14s
# J08tg9/3ahctk+0iXuLp/+UOT1pfMPDblQQ7QhLegc9PF0BJH+3DEMr0x7IXnquF
# BSzMgkvAFHUXwGmLOeatJjC1ryMk379hqIIt1eBx6852ye/ID0A3H42Od7v+Y2si
# AFPxSLu8NoLuuhzlsKqdY4lhRZ5vbflD3WGPxC92A747x9uRGCO5QipXSVJVviFL
# D1ZlACyUIRdpH4Ex3x+hfjr7rkJm63KiG9u3S0GYwZ5uU3x3RjA/h6e5F0lscWJa
# blzdQy335fx0Y5i2hoCBRue8IfYWbXy69JWQFDGCAdYwggHSAgEBMDUwITEfMB0G
# A1UEAwwWV2luR2V0TWFuYWdlciBMb2NhbERldgIQERy/5noS0YNDQ+ns6effbDAJ
# BgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0B
# CQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAj
# BgkqhkiG9w0BCQQxFgQUoC1y7LFE61Mqe9b7FlMU/NbwGokwDQYJKoZIhvcNAQEB
# BQAEggEAPUYiKq6X9S1ucd9lKHmTz2QZ10g1mKV52hI2m6d67kSewGmauT3Xd6dj
# rGAOMvdiDsNWUk1tHsDrl8KX528QfwDdJ3/z2Pl+DfH5y0BYJ1mIKYIle87puOEd
# Ij+NKg3T9O7+YoDf6PvrnsyGM1oHdUooM//DoMOn9siDFY00DTTJWkwrDDyifziC
# 7mDH8LiA2FxRvHvoFRwSobRsVdcCY/fTqlmGak97Ta+hoXuy0cKErATCS94zbpXt
# kosRpXKPXdOM6g8VLAkZTlUxank6PLOZHHoaUZAN4FxZZtG33UW+71+4tLKO/nQX
# EmD2rRFbUPwrjpyNcB4GBmAnWBkKvQ==
# SIG # End signature block
