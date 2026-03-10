function anatomicalROIs = defineAnatomicalROIs(baseROI)
    % Define anatomically-informed regions of interest for INTERNAL vocal tract structures
    % Only includes structures that are actually visible in your vocal tract videos
    anatomicalROIs = struct();
    
    % Extract base ROI dimensions
    x = baseROI(1);
    y = baseROI(2);
    w = baseROI(3);
    h = baseROI(4);
    
    % Define anatomical regions based on internal vocal tract anatomy
    % Adjust these coordinates based on your specific imaging setup and orientation
    
    % === PHARYNX REGION ===
    % Upper part of the vocal tract - pharyngeal cavity
    anatomicalROIs.pharynx = [x + 0.1*w, y + 0.1*h, 0.8*w, 0.4*h];
    
    % === LARYNX REGION ===
    % Lower part - laryngeal area including vocal folds
    anatomicalROIs.larynx = [x + 0.2*w, y + 0.5*h, 0.6*w, 0.4*h];
    
    % === EPIGLOTTIS REGION ===
    % Transition area between pharynx and larynx
    anatomicalROIs.epiglottis = [x + 0.25*w, y + 0.35*h, 0.5*w, 0.25*h];
    
    % === VOCAL FOLDS REGION ===
    % Central area where vocal fold movement occurs
    anatomicalROIs.vocal_folds = [x + 0.3*w, y + 0.6*h, 0.4*w, 0.2*h];
    
    % === ADDITIONAL REGIONS (uncomment and adjust if visible in your setup) ===
    
    % ARYTENOID REGION (if visible)
    % anatomicalROIs.arytenoid = [x + 0.35*w, y + 0.55*h, 0.3*w, 0.15*h];
    
    % VENTRICULAR FOLDS (if distinguishable from vocal folds)
    % anatomicalROIs.ventricular_folds = [x + 0.32*w, y + 0.5*h, 0.36*w, 0.15*h];
    
    % PYRIFORM SINUSES (if visible)
    % anatomicalROIs.pyriform_left = [x + 0.1*w, y + 0.4*h, 0.25*w, 0.3*h];
    % anatomicalROIs.pyriform_right = [x + 0.65*w, y + 0.4*h, 0.25*w, 0.3*h];
end
