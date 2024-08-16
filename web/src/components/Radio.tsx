import { 
  Button, 
  Box, 
  Image, 
  Tooltip, 
  TextInput, 
  ActionIcon,
  Grid,
  Select,
  Text
} from '@mantine/core';
import { useState, useEffect } from "react";
import { fetchNui } from "../utils/fetchNui";
import classes from "./Radio.module.css";
import { 
  IconBuildingBroadcastTower, 
  IconAdjustments, 
  IconBellRingingFilled, 
  IconArrowLeft, 
  IconArrowRight 
} from '@tabler/icons-react';
import { useNuiEvent } from "../hooks/useNuiEvent";

export default function Radio() {
  const [isOn, setIsOn] = useState(false);
  const [selectedIcon, setSelectedIcon] = useState(0);
  const [radioNumber, setRadioNumber] = useState("");
  const [currentChannel, setCurrentChannel] = useState<number | null>(null);
  const [currentScreen, setCurrentScreen] = useState("main");

  const togglePower = async () => {
    const newIsOn = !isOn;
    setIsOn(newIsOn);
    await fetchNui('powerButton');
    if (!newIsOn) {
      setCurrentScreen("main");
    }
  };

  const connectToRadioChannel = async (channel: number) => {
    if (currentChannel === channel) {
      console.log('Already connected to this channel');
      return;
    }

    try {
      await fetchNui('connectToRadio', { channel });
      setCurrentChannel(channel); 
      setCurrentScreen("main");
    } catch (error) {
      console.error('Failed to connect to radio channel:', error);
    }
  };

  const leaveRadioChannel = async () => {
    try {
      await fetchNui('leaveRadio');
      setCurrentChannel(null);
      setRadioNumber("");
      setCurrentScreen("main");
    } catch (error) {
      console.error('Failed to leave radio channel:', error);
    }
  };

  const triggerNotification = async () => {
    try {
      await fetchNui('triggerNotification');
      console.log('Notification sent');
    } catch (error) {
      console.error('Failed to trigger notification:', error);
    }
  };

  const volumeUp = async () => {
    try {
      await fetchNui('volumeUp');
      await playSound('Next');
    } catch (error) {
      console.error('Failed to increase volume:', error);
    }
  };

  const volumeDown = async () => {
    try {
      await fetchNui('volumeDown');
      await playSound('Next');
    } catch (error) {
      console.error('Failed to decrease volume:', error);
    }
  };

  const setMicClicks = async (value: boolean) => {
    try {
      await fetchNui('toggleClicks', { micClicks: value });
      await playSound('Next');
    } catch (error) {
      console.error('Failed to toggle mic clicks:', error);
    }
  };

  const icons = [
    <IconBuildingBroadcastTower style={{ width: '70%', height: '70%' }} stroke={1.5} />,
    <IconBellRingingFilled style={{ width: '70%', height: '70%' }} stroke={1.5} />,
    <IconAdjustments style={{ width: '70%', height: '70%' }} stroke={1.5} />
  ];

  const playSound = async (soundName: string) => {
    try {
      await fetchNui('playSound', { soundName });
    } catch (error) {
      console.error('Failed to play sound:', error);
    }
  };

  const handleLeftArrowClick = async () => {
    setSelectedIcon((prev) => (prev === 0 ? icons.length - 1 : prev - 1));
    await playSound('Next');
  };
  
  const handleRightArrowClick = async () => {
    setSelectedIcon((prev) => (prev === icons.length - 1 ? 0 : prev + 1));
    await playSound('Next');
  };

  const handleRadioNumberChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const value = event.target.value;
  
    // Regular expression to validate the input:
    // - Allow up to 3 digits before the decimal point
    // - Allow only one decimal point
    // - Allow up to 1 digit after the decimal point
    const regex = /^\d{0,3}(\.\d{0,2})?$/;
  
    if (regex.test(value)) {
      setRadioNumber(value);
    }
  };

  const handleConfirm = async () => {
    if (selectedIcon === 0) {
      if (radioNumber.trim() !== "") {
        const channel = parseFloat(radioNumber);
        if (!isNaN(channel)) {
          await connectToRadioChannel(channel);
        } else {
          console.error("Invalid radio number");
        }
      }
    } else if (selectedIcon === 1) {
      await triggerNotification();
    } else if (selectedIcon === 2) {
      setCurrentScreen("settings");
    }
  };

  useEffect(() => {
    if (currentChannel !== null) {
      setRadioNumber(currentChannel.toString());
    }
  }, [currentChannel]);

  return (
    <Box className={classes.app_container}>
      <Image 
        src="https://files.fivemerr.com/images/2fcbc905-abfa-401a-ad6e-b7415155c411.png" 
        alt="Radio Background" 
        className={classes.radio_image}
        fit="cover"
        width="100%"
        height="100%"
      />
      
      <Box
        className={classes.screen}
        style={{
          backgroundColor: isOn ? '#1b1d21' : '#1b1d21',
          position: 'relative',
          width: '150px',
          height: '130px',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          transition: 'background-color 0.3s ease',
        }}
      >
        {isOn && currentScreen === "main" && (
          <>
            <Grid
              style={{
                margin: '10%',
                display: 'flex',
                flexWrap: 'wrap',
                justifyContent: 'center',
                alignItems: 'center',
                marginRight: '15px',
                zIndex: 4
              }}
              gutter="xs"
            >
              {icons.map((icon, index) => (
                <Grid.Col
                  key={index}
                  span={4}
                  style={{ 
                    display: 'flex', 
                    justifyContent: 'center', 
                    alignItems: 'center',
                    borderRadius: '50%',
                    zIndex: 4
                  }}
                >
                  <ActionIcon 
                    variant="light" 
                    color={selectedIcon === index ? "blue.5" : "teal.5"} 
                    size="lg"
                  >
                    {icon}
                  </ActionIcon>
                </Grid.Col>
              ))}
            </Grid>
            <Box style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', zIndex: 4 }}>
              {selectedIcon === 0 && (
                <>
                  <TextInput
                    leftSection={<IconBuildingBroadcastTower style={{ width: '70%', height: '60%'}} stroke={1.5}/>}
                    value={radioNumber}
                    onChange={handleRadioNumberChange}
                    style={{ marginBottom: '10px', width: '130px'}}
                  />
                </>
              )}
            </Box>
          </>
        )}

        {isOn && currentScreen === "settings" && (
          <Box style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', zIndex: 4, marginTop: '10px'}}>
            <Text>Volume</Text>
            <Box style={{ display: 'flex', flexDirection: 'row', justifyContent: 'center', margin: '1px' }}>
              <Button size="xs" variant="light" color="teal" onClick={volumeUp} style={{ margin: '1px', width: '70px' }}>Up</Button>
              <Button size="xs" variant="light" color="teal" onClick={volumeDown} style={{ margin: '1px', width: '70px' }}>Down</Button>
            </Box>
            <Box style={{ margin: '3px' }}>
            <Select
              label="Mic Clicks"
              placeholder="Select"
              data={[
                { value: 'true', label: 'True' },
                { value: 'false', label: 'False' }
              ]}
              onChange={(value) => setMicClicks(value === 'true')}
              size="xs"
            />
            </Box>
          </Box>
        )}
      </Box>

      <Button className={classes.power_button} variant="transparent" color="teal" onClick={togglePower} style={{ zIndex: 3 }} />

      <Box className={classes.arrow_buttons_container} style={{ zIndex: 3 }}>
        <Tooltip label="Previous" bg="dark" color="light">
          <Button variant="transparent" color="teal" size="xs" onClick={handleLeftArrowClick} className={classes.arrow_button}>
          </Button>
        </Tooltip>
        <Tooltip label="Next" bg="dark" color="light">
          <Button variant="transparent" color="teal" size="xs" onClick={handleRightArrowClick} className={classes.arrow_button}>
          </Button>
        </Tooltip>
      </Box>

      <Box className={classes.additional_buttons_container} style={{ zIndex: 3, display: 'flex', justifyContent: 'space-between', margin: '0 10px' }}>
        <Tooltip label="Confirm" bg="dark" color="light">
          <Button variant="transparent" color="blue" size="xs" style={{margin: '0 45px' }} onClick={handleConfirm}>
          </Button>
        </Tooltip>
        <Tooltip label="Leave" bg="dark" color="light">
          <Button variant="transparent" color="blue" size="xs" style={{margin: '0 40px' }} onClick={() => {
              if (currentScreen === "settings") {
                setCurrentScreen("main");
                playSound('Next');
              } else {
                leaveRadioChannel();
              }
            }}>
          </Button>
        </Tooltip>
      </Box>
    </Box>
  );
}
