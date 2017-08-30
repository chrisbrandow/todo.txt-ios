/**
 * This file is part of Todo.txt, an iOS app for managing your todo.txt file.
 *
 * @author Todo.txt contributors <todotxt@yahoogroups.com>
 * @copyright 2011-2013 Todo.txt contributors (http://todotxt.com)
 *  
 * Dual-licensed under the GNU General Public License and the MIT License
 *
 * @license GNU General Public License http://www.gnu.org/licenses/gpl.html
 *
 * Todo.txt is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any
 * later version.
 *
 * Todo.txt is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with Todo.txt.  If not, see
 * <http://www.gnu.org/licenses/>.
 *
 *
 * @license The MIT License http://www.opensource.org/licenses/mit-license.php
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "FilterFactory.h"
#import "AndFilter.h"
#import "ByPriorityFilter.h"
#import "ByContextFilter.h"
#import "ByProjectFilter.h"
#import "ByTextFilter.h"

#import "Util.h"
#import "Task.h"

@interface BySDMFilter : NSObject <Filter>
- (BOOL)apply:(id)object;
@end

@implementation BySDMFilter

- (BOOL)apply:(id)object {
//this acutally needs to be incorporated into settings view
    Task *input = (Task *)object;
    NSDate *date = [Util dateFromString:input.prependedDate withFormat:txtDateFormat];
    //Todo: need to make this a proper date-based thing
    //Todo: need to have a way to turn it off and on.

    if ([[NSDate date] timeIntervalSinceDate:date] < 24*60*60*14 || [input.originalText containsString:@"sdm:"] || input.priority.name == PriorityZ) {
        return YES;
    }
    
    return NO;
}
@end

//TODO - make "today" filter as well along with way to turn off and on (just a state-button at bottom bar)
//make that the right slide option

@implementation FilterFactory

+ (id <Filter>) getAndFilterWithPriorities:(NSArray*)priorities 
								  contexts:(NSArray*)contexts 
								  projects:(NSArray*)projects 
									  text:(NSString*)text 
                                    scopes:(NSArray *)scopes
							 caseSensitive:(BOOL)caseSensitive {

	AndFilter *filter = [[AndFilter alloc] init];
	if (priorities.count > 0) {
		[filter addFilter:[[ByPriorityFilter alloc] initWithPriorities:priorities]];
	}
	
	if (contexts.count > 0) {
        ByContextFilter *cFilter = [[ByContextFilter alloc] initWithContexts:contexts];
		[filter addFilter:cFilter];
	}
	
	if (projects.count > 0) {
		[filter addFilter:[[ByProjectFilter alloc] initWithProjects:projects]];
	}

    if (scopes.count > 0) {
        [filter addFilter:[[BySDMFilter alloc] init]];
    }
	
	if (text.length > 0) {
		[filter addFilter:[[ByTextFilter alloc] initWithText:text caseSensitive:caseSensitive]];
	}
	return filter;
}

@end
