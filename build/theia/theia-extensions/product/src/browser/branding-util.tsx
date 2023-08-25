/********************************************************************************
 * Copyright (C) 2020 EclipseSource and others.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v. 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0.
 *
 * This Source Code may also be made available under the following Secondary
 * Licenses when the conditions for such availability set forth in the Eclipse
 * Public License v. 2.0 are satisfied: GNU General Public License, version 2
 * with the GNU Classpath Exception which is available at
 * https://www.gnu.org/software/classpath/license.html.
 *
 * SPDX-License-Identifier: EPL-2.0 OR GPL-2.0 WITH Classpath-exception-2.0
 ********************************************************************************/

import { Key, KeyCode } from '@theia/core/lib/browser';
import { WindowService } from '@theia/core/lib/browser/window/window-service';
import * as React from 'react';

export interface ExternalBrowserLinkProps {
    text: string;
    url: string;
    windowService: WindowService;
}

function ExternalBrowserLink(props: ExternalBrowserLinkProps): JSX.Element {
    return <a
        role={'button'}
        tabIndex={0}
        onClick={() => openExternalLink(props.url, props.windowService)}
        onKeyDown={(e: React.KeyboardEvent) => {
            if (Key.ENTER.keyCode === KeyCode.createKeyCode(e.nativeEvent).key?.keyCode) {
                openExternalLink(props.url, props.windowService);
            }
        }}>
        {props.text}
    </a>;
}

function openExternalLink(url: string, windowService: WindowService): void {
    windowService.openNewWindow(url, { external: true });
}

export function renderAboutYourTraining(windowService: WindowService): React.ReactNode {
    return <div className='gs-section'>
        <h3 className='gs-section-header'>
            About your Training
        </h3>
        <div >
            Your teacher will provide you with all the necessary information on how to use your training environment.

            Visit <ExternalBrowserLink text="documentation" url="https://acend.ch"
                windowService={windowService} ></ExternalBrowserLink> to see what other trainings we provide.
        </div>
    </div>;
}

